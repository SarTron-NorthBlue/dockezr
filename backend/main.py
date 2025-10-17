from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import asyncpg
from datetime import datetime, date, time
import os
import time as time_module
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

# Configuration de la base de données
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@db:5432/dockezr")

# Pool de connexions
pool = None

# Métriques Prometheus
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])
RESERVATION_COUNT = Counter('reservations_total', 'Total reservations created', ['room_name'])
ROOM_ACCESS_COUNT = Counter('room_access_total', 'Total room accesses', ['room_name'])

# Modèles Pydantic pour les Salles
class RoomCreate(BaseModel):
    name: str
    capacity: int
    equipment: Optional[str] = None
    description: Optional[str] = None

class Room(BaseModel):
    id: int
    name: str
    capacity: int
    equipment: Optional[str]
    description: Optional[str]

# Modèles Pydantic pour les Réservations
class ReservationCreate(BaseModel):
    room_id: int
    user_name: str
    user_email: Optional[str] = None
    reservation_date: date
    start_time: time
    end_time: time
    purpose: str

class Reservation(BaseModel):
    id: int
    room_id: int
    room_name: Optional[str] = None
    user_name: str
    user_email: Optional[str] = None
    reservation_date: date
    start_time: time
    end_time: time
    purpose: str
    created_at: datetime

# Application FastAPI
app = FastAPI(
    title="Expernet - Système de Réservation de Salles",
    version="1.0.0",
    description="API de gestion des réservations de salles pour le centre de formation Expernet"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://frontend:3000", "http://141.253.118.141:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Middleware pour les métriques Prometheus
@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time_module.time()
    
    # Extraire les informations de la requête
    method = request.method
    endpoint = request.url.path
    
    # Traiter la requête
    response = await call_next(request)
    
    # Calculer la durée
    duration = time_module.time() - start_time
    
    # Enregistrer les métriques
    REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=response.status_code).inc()
    REQUEST_DURATION.labels(method=method, endpoint=endpoint).observe(duration)
    
    return response

@app.on_event("startup")
async def startup():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL)
    # Créer les tables si elles n'existent pas
    async with pool.acquire() as conn:
        # Table des salles
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS rooms (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL UNIQUE,
                capacity INTEGER NOT NULL,
                equipment TEXT,
                description TEXT
            )
        ''')
        
        # Table des réservations
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS reservations (
                id SERIAL PRIMARY KEY,
                room_id INTEGER NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
                user_name VARCHAR(255) NOT NULL,
                user_email VARCHAR(255),
                reservation_date DATE NOT NULL,
                start_time TIME NOT NULL,
                end_time TIME NOT NULL,
                purpose TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        
        # Insérer des salles par défaut si la table est vide
        count = await conn.fetchval('SELECT COUNT(*) FROM rooms')
        if count == 0:
            await conn.execute('''
                INSERT INTO rooms (name, capacity, equipment, description) VALUES
                ('Salle Atlas', 30, 'Vidéoprojecteur, Tableau blanc, WiFi', 'Grande salle de formation idéale pour les cours'),
                ('Salle Horizon', 15, 'Écran TV, Tableau blanc, WiFi', 'Salle de réunion moyenne capacité'),
                ('Salle Innovation', 50, 'Vidéoprojecteur, Sono, WiFi, Climatisation', 'Salle de conférence grande capacité'),
                ('Salle Connect', 8, 'Écran TV, Visioconférence, WiFi', 'Petite salle pour réunions d''équipe'),
                ('Salle Digital', 20, '20 postes informatiques, Vidéoprojecteur, WiFi', 'Salle informatique pour formations pratiques')
            ''')

@app.on_event("shutdown")
async def shutdown():
    await pool.close()

@app.get("/")
async def root():
    return {"message": "Bienvenue sur le système de réservation de salles Expernet!", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "database": "connected"}

@app.get("/metrics")
async def metrics():
    """Endpoint pour les métriques Prometheus"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

# === ROUTES POUR LES SALLES ===

@app.get("/rooms", response_model=List[Room])
async def get_rooms():
    """Récupérer toutes les salles"""
    async with pool.acquire() as conn:
        rows = await conn.fetch('SELECT * FROM rooms ORDER BY name')
        return [dict(row) for row in rows]

@app.get("/rooms/{room_id}", response_model=Room)
async def get_room(room_id: int):
    """Récupérer une salle spécifique"""
    async with pool.acquire() as conn:
        row = await conn.fetchrow('SELECT * FROM rooms WHERE id = $1', room_id)
        if row is None:
            raise HTTPException(status_code=404, detail="Salle non trouvée")
        
        # Enregistrer l'accès à la salle
        ROOM_ACCESS_COUNT.labels(room_name=row['name']).inc()
        
        return dict(row)

@app.post("/rooms", response_model=Room)
async def create_room(room: RoomCreate):
    """Créer une nouvelle salle"""
    async with pool.acquire() as conn:
        try:
            row = await conn.fetchrow(
                'INSERT INTO rooms (name, capacity, equipment, description) VALUES ($1, $2, $3, $4) RETURNING *',
                room.name, room.capacity, room.equipment, room.description
            )
            return dict(row)
        except asyncpg.UniqueViolationError:
            raise HTTPException(status_code=400, detail="Une salle avec ce nom existe déjà")

@app.delete("/rooms/{room_id}")
async def delete_room(room_id: int):
    """Supprimer une salle"""
    async with pool.acquire() as conn:
        result = await conn.execute('DELETE FROM rooms WHERE id = $1', room_id)
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Salle non trouvée")
        return {"message": "Salle supprimée avec succès"}

# === ROUTES POUR LES RÉSERVATIONS ===

@app.get("/reservations", response_model=List[Reservation])
async def get_reservations():
    """Récupérer toutes les réservations avec les informations des salles"""
    async with pool.acquire() as conn:
        rows = await conn.fetch('''
            SELECT r.*, ro.name as room_name 
            FROM reservations r
            JOIN rooms ro ON r.room_id = ro.id
            ORDER BY r.reservation_date DESC, r.start_time DESC
        ''')
        return [dict(row) for row in rows]

@app.get("/reservations/room/{room_id}", response_model=List[Reservation])
async def get_reservations_by_room(room_id: int):
    """Récupérer les réservations d'une salle spécifique"""
    async with pool.acquire() as conn:
        rows = await conn.fetch('''
            SELECT r.*, ro.name as room_name 
            FROM reservations r
            JOIN rooms ro ON r.room_id = ro.id
            WHERE r.room_id = $1
            ORDER BY r.reservation_date, r.start_time
        ''', room_id)
        return [dict(row) for row in rows]

@app.get("/reservations/date/{reservation_date}")
async def get_reservations_by_date(reservation_date: date):
    """Récupérer les réservations pour une date spécifique"""
    async with pool.acquire() as conn:
        rows = await conn.fetch('''
            SELECT r.*, ro.name as room_name 
            FROM reservations r
            JOIN rooms ro ON r.room_id = ro.id
            WHERE r.reservation_date = $1
            ORDER BY r.start_time
        ''', reservation_date)
        return [dict(row) for row in rows]

@app.post("/reservations", response_model=Reservation)
async def create_reservation(reservation: ReservationCreate):
    """Créer une nouvelle réservation"""
    async with pool.acquire() as conn:
        # Vérifier que la salle existe
        room = await conn.fetchrow('SELECT * FROM rooms WHERE id = $1', reservation.room_id)
        if room is None:
            raise HTTPException(status_code=404, detail="Salle non trouvée")
        
        # Vérifier que l'heure de fin est après l'heure de début
        if reservation.end_time <= reservation.start_time:
            raise HTTPException(status_code=400, detail="L'heure de fin doit être après l'heure de début")
        
        # Vérifier les conflits de réservation
        conflicts = await conn.fetch('''
            SELECT * FROM reservations 
            WHERE room_id = $1 
            AND reservation_date = $2
            AND (
                (start_time < $4 AND end_time > $3)
                OR (start_time >= $3 AND start_time < $4)
            )
        ''', reservation.room_id, reservation.reservation_date, 
            reservation.start_time, reservation.end_time)
        
        if conflicts:
            raise HTTPException(
                status_code=409, 
                detail="La salle est déjà réservée pour ce créneau horaire"
            )
        
        # Créer la réservation
        row = await conn.fetchrow('''
            INSERT INTO reservations 
            (room_id, user_name, user_email, reservation_date, start_time, end_time, purpose, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING *
        ''', reservation.room_id, reservation.user_name, reservation.user_email,
            reservation.reservation_date, reservation.start_time, reservation.end_time,
            reservation.purpose, datetime.utcnow())
        
        result = dict(row)
        result['room_name'] = room['name']
        
        # Enregistrer la création de réservation
        RESERVATION_COUNT.labels(room_name=room['name']).inc()
        
        return result

@app.delete("/reservations/{reservation_id}")
async def delete_reservation(reservation_id: int):
    """Annuler une réservation"""
    async with pool.acquire() as conn:
        result = await conn.execute('DELETE FROM reservations WHERE id = $1', reservation_id)
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Réservation non trouvée")
        return {"message": "Réservation annulée avec succès"}

