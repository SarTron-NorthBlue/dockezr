'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import { 
  BuildingOffice2Icon, 
  CalendarIcon, 
  ClipboardDocumentListIcon,
  ChartBarIcon,
  UserGroupIcon,
  WrenchScrewdriverIcon,
  CheckCircleIcon,
  XCircleIcon,
  ClockIcon,
  EnvelopeIcon,
  DocumentTextIcon,
  TrashIcon,
  CheckIcon,
  XMarkIcon
} from '@heroicons/react/24/outline'

interface Room {
  id: number
  name: string
  capacity: number
  equipment: string | null
  description: string | null
}

interface Reservation {
  id: number
  room_id: number
  room_name?: string
  user_name: string
  user_email: string
  reservation_date: string
  start_time: string
  end_time: string
  purpose: string
  created_at: string
}

export default function Home() {
  const [rooms, setRooms] = useState<Room[]>([])
  const [reservations, setReservations] = useState<Reservation[]>([])
  const [selectedRoom, setSelectedRoom] = useState<number | null>(null)
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'rooms' | 'reservations' | 'planning'>('planning')
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0])
  
  // Formulaire de réservation
  const [formData, setFormData] = useState({
    user_name: '',
    user_email: '',
    reservation_date: '',
    start_time: '',
    end_time: '',
    purpose: ''
  })

  const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

  useEffect(() => {
    fetchRooms()
    fetchReservations()
  }, [])

  const fetchRooms = async () => {
    try {
      const response = await axios.get(`${API_URL}/rooms`)
      setRooms(response.data)
    } catch (error) {
      console.error('Erreur lors du chargement des salles:', error)
    }
  }

  const fetchReservations = async () => {
    try {
      const response = await axios.get(`${API_URL}/reservations`)
      setReservations(response.data)
    } catch (error) {
      console.error('Erreur lors du chargement des réservations:', error)
    }
  }

  const fetchReservationsByDate = async (date: string) => {
    try {
      const response = await axios.get(`${API_URL}/reservations/date/${date}`)
      return response.data
    } catch (error) {
      console.error('Erreur lors du chargement des réservations par date:', error)
      return []
    }
  }

  const getReservationsForRoom = (roomId: number, date: string) => {
    return reservations.filter(r => 
      r.room_id === roomId && 
      r.reservation_date === date
    )
  }

  const isSlotAvailable = (roomId: number, date: string, startTime: string, endTime: string) => {
    const roomReservations = getReservationsForRoom(roomId, date)
    
    for (const reservation of roomReservations) {
      const resStart = reservation.start_time
      const resEnd = reservation.end_time
      
      // Vérifie s'il y a chevauchement
      if ((startTime < resEnd && endTime > resStart)) {
        return false
      }
    }
    return true
  }

  const handleReservation = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedRoom) {
      alert('Veuillez sélectionner une salle')
      return
    }

    setLoading(true)
    try {
      await axios.post(`${API_URL}/reservations`, {
        room_id: selectedRoom,
        ...formData
      })
      
      alert('Réservation effectuée avec succès !')
      setFormData({
        user_name: '',
        user_email: '',
        reservation_date: '',
        start_time: '',
        end_time: '',
        purpose: ''
      })
      setSelectedRoom(null)
      fetchReservations()
    } catch (error: any) {
      if (error.response?.status === 409) {
        alert('Cette salle est déjà réservée pour ce créneau horaire')
      } else {
        alert('Erreur lors de la réservation: ' + (error.response?.data?.detail || error.message))
      }
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteReservation = async (id: number) => {
    if (!confirm('Voulez-vous vraiment annuler cette réservation ?')) return
    
    try {
      await axios.delete(`${API_URL}/reservations/${id}`)
      fetchReservations()
      alert('Réservation annulée avec succès')
    } catch (error) {
      console.error('Erreur lors de l\'annulation:', error)
      alert('Erreur lors de l\'annulation de la réservation')
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-3 mb-2">
            <BuildingOffice2Icon className="w-12 h-12 text-indigo-900" />
            <h1 className="text-5xl font-bold text-indigo-900">
              Expernet
            </h1>
          </div>
          <p className="text-xl text-gray-600">
            Centre de Formation - Réservation de Salles
          </p>
        </div>

        {/* Tabs */}
        <div className="flex justify-center mb-8">
          <div className="bg-white rounded-lg shadow-md p-1 inline-flex">
            <button
              onClick={() => setActiveTab('planning')}
              className={`px-6 py-2 rounded-md font-medium transition-colors flex items-center gap-2 ${
                activeTab === 'planning'
                  ? 'bg-indigo-600 text-white'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <ChartBarIcon className="w-5 h-5" />
              Planning des salles
            </button>
            <button
              onClick={() => setActiveTab('rooms')}
              className={`px-6 py-2 rounded-md font-medium transition-colors flex items-center gap-2 ${
                activeTab === 'rooms'
                  ? 'bg-indigo-600 text-white'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <CalendarIcon className="w-5 h-5" />
              Réserver une salle
            </button>
            <button
              onClick={() => setActiveTab('reservations')}
              className={`px-6 py-2 rounded-md font-medium transition-colors flex items-center gap-2 ${
                activeTab === 'reservations'
                  ? 'bg-indigo-600 text-white'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <ClipboardDocumentListIcon className="w-5 h-5" />
              Mes réservations
            </button>
          </div>
        </div>

        {/* Onglet Planning */}
        {activeTab === 'planning' && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <div className="mb-6">
              <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                Planning des Salles
              </h2>
              <div className="flex items-center gap-4 mb-6">
                <label className="text-sm font-medium text-gray-700">
                  Date :
                </label>
                <input
                  type="date"
                  value={selectedDate}
                  onChange={(e) => setSelectedDate(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Grille de planning */}
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="bg-indigo-50">
                    <th className="border border-gray-300 px-4 py-2 text-left font-semibold text-gray-700">
                      Salle
                    </th>
                    {Array.from({ length: 14 }, (_, i) => i + 8).map((hour) => (
                      <th key={hour} className="border border-gray-300 px-2 py-2 text-center text-sm font-medium text-gray-700">
                        {hour}h
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {rooms.map((room) => {
                    const roomReservations = getReservationsForRoom(room.id, selectedDate)
                    
                    return (
                      <tr key={room.id} className="hover:bg-gray-50">
                        <td className="border border-gray-300 px-4 py-2 font-medium text-gray-900 whitespace-nowrap">
                          {room.name}
                          <div className="text-xs text-gray-500 flex items-center gap-1">
                            <UserGroupIcon className="w-3 h-3" />
                            {room.capacity} pers.
                          </div>
                        </td>
                        {Array.from({ length: 14 }, (_, i) => i + 8).map((hour) => {
                          const hourStart = `${hour.toString().padStart(2, '0')}:00`
                          const hourEnd = `${(hour + 1).toString().padStart(2, '0')}:00`
                          
                          // Trouver les réservations qui couvrent cette heure
                          const overlappingReservations = roomReservations.filter(res => {
                            return res.start_time < hourEnd && res.end_time > hourStart
                          })

                          const isOccupied = overlappingReservations.length > 0
                          const reservation = overlappingReservations[0]

                          return (
                            <td
                              key={hour}
                              className={`border border-gray-300 px-1 py-2 text-center text-xs ${
                                isOccupied ? 'bg-red-100' : 'bg-green-50'
                              }`}
                              title={
                                reservation
                                  ? `${reservation.user_name} - ${reservation.purpose}\n${reservation.start_time} - ${reservation.end_time}`
                                  : 'Disponible'
                              }
                            >
                              {isOccupied ? (
                                <div className="text-red-700 font-medium">
                                  <XMarkIcon className="w-4 h-4 mx-auto" />
                                  <div className="text-[10px] mt-1 truncate">
                                    {reservation.user_name}
                                  </div>
                                </div>
                              ) : (
                                <div className="text-green-600">
                                  <CheckIcon className="w-4 h-4 mx-auto" />
                                </div>
                              )}
                            </td>
                          )
                        })}
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>

            {/* Légende */}
            <div className="mt-6 flex gap-6 justify-center">
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 bg-green-50 border border-gray-300 flex items-center justify-center text-green-600">
                  <CheckIcon className="w-4 h-4" />
                </div>
                <span className="text-sm text-gray-700">Disponible</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 bg-red-100 border border-gray-300 flex items-center justify-center text-red-700">
                  <XMarkIcon className="w-4 h-4" />
                </div>
                <span className="text-sm text-gray-700">Réservé</span>
              </div>
            </div>

            {/* Liste des réservations du jour */}
            <div className="mt-8">
              <h3 className="text-lg font-semibold mb-4 text-gray-800">
                Réservations du {new Date(selectedDate).toLocaleDateString('fr-FR')}
              </h3>
              {reservations.filter(r => r.reservation_date === selectedDate).length === 0 ? (
                <p className="text-gray-500 text-center py-4">Aucune réservation pour cette date</p>
              ) : (
                <div className="space-y-3">
                  {reservations
                    .filter(r => r.reservation_date === selectedDate)
                    .sort((a, b) => a.start_time.localeCompare(b.start_time))
                    .map((reservation) => (
                      <div
                        key={reservation.id}
                        className="border border-gray-200 rounded-lg p-3 bg-gray-50"
                      >
                        <div className="flex justify-between items-start">
                          <div>
                            <span className="font-semibold text-indigo-900">{reservation.room_name}</span>
                            <span className="mx-2">•</span>
                            <span className="text-gray-700">{reservation.start_time} - {reservation.end_time}</span>
                          </div>
                          <div className="text-right text-sm">
                            <div className="font-medium text-gray-900">{reservation.user_name}</div>
                            <div className="text-gray-600">{reservation.purpose}</div>
                          </div>
                        </div>
                      </div>
                    ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* Onglet Réservation */}
        {activeTab === 'rooms' && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Liste des salles */}
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                Nos Salles Disponibles
              </h2>
              <div className="space-y-4 max-h-[600px] overflow-y-auto">
                {rooms.map((room) => (
                  <div
                    key={room.id}
                    onClick={() => setSelectedRoom(room.id)}
                    className={`border-2 rounded-lg p-4 cursor-pointer transition-all ${
                      selectedRoom === room.id
                        ? 'border-indigo-600 bg-indigo-50'
                        : 'border-gray-200 hover:border-indigo-300'
                    }`}
                  >
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <h3 className="text-lg font-bold text-gray-900">
                          {room.name}
                        </h3>
                        <p className="text-sm text-gray-600 mt-1 flex items-center gap-1">
                          <UserGroupIcon className="w-4 h-4" />
                          Capacité: {room.capacity} personnes
                        </p>
                        {room.equipment && (
                          <p className="text-sm text-gray-600 mt-1 flex items-center gap-1">
                            <WrenchScrewdriverIcon className="w-4 h-4" />
                            {room.equipment}
                          </p>
                        )}
                        {room.description && (
                          <p className="text-sm text-gray-500 mt-2">
                            {room.description}
                          </p>
                        )}
                      </div>
                      {selectedRoom === room.id && (
                        <div className="ml-2">
                          <span className="inline-block bg-indigo-600 text-white rounded-full p-2">
                            <CheckIcon className="w-4 h-4" />
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Formulaire de réservation */}
            <div className="bg-white rounded-lg shadow-lg p-6">
              <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                Formulaire de Réservation
              </h2>
              {!selectedRoom ? (
                <div className="text-center py-12 text-gray-500">
                  <BuildingOffice2Icon className="w-16 h-16 mx-auto mb-4 text-gray-400" />
                  <p className="text-lg">Sélectionnez une salle pour continuer</p>
                </div>
              ) : (
                <form onSubmit={handleReservation} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Votre nom *
                    </label>
                    <input
                      type="text"
                      value={formData.user_name}
                      onChange={(e) => setFormData({ ...formData, user_name: e.target.value })}
                      required
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      placeholder="Jean Dupont"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Email (optionnel)
                    </label>
                    <input
                      type="email"
                      value={formData.user_email}
                      onChange={(e) => setFormData({ ...formData, user_email: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      placeholder="jean.dupont@expernet.fr"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Date *
                    </label>
                    <input
                      type="date"
                      value={formData.reservation_date}
                      onChange={(e) => setFormData({ ...formData, reservation_date: e.target.value })}
                      required
                      min={new Date().toISOString().split('T')[0]}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Heure de début *
                      </label>
                      <input
                        type="time"
                        value={formData.start_time}
                        onChange={(e) => setFormData({ ...formData, start_time: e.target.value })}
                        required
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Heure de fin *
                      </label>
                      <input
                        type="time"
                        value={formData.end_time}
                        onChange={(e) => setFormData({ ...formData, end_time: e.target.value })}
                        required
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Objet de la réservation *
                    </label>
                    <textarea
                      value={formData.purpose}
                      onChange={(e) => setFormData({ ...formData, purpose: e.target.value })}
                      required
                      rows={3}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                      placeholder="Formation Python, Réunion d'équipe, etc."
                    />
                  </div>

                  {/* Vérification de disponibilité */}
                  {selectedRoom && formData.reservation_date && formData.start_time && formData.end_time && (
                    <div className={`p-3 rounded-lg ${
                      isSlotAvailable(selectedRoom, formData.reservation_date, formData.start_time, formData.end_time)
                        ? 'bg-green-50 border border-green-200'
                        : 'bg-red-50 border border-red-200'
                    }`}>
                      {isSlotAvailable(selectedRoom, formData.reservation_date, formData.start_time, formData.end_time) ? (
                        <div className="flex items-center gap-2 text-green-700">
                          <CheckCircleIcon className="w-6 h-6" />
                          <span className="font-medium">Ce créneau est disponible !</span>
                        </div>
                      ) : (
                        <div className="flex items-center gap-2 text-red-700">
                          <XCircleIcon className="w-6 h-6" />
                          <span className="font-medium">Ce créneau est déjà réservé. Choisissez un autre horaire.</span>
                        </div>
                      )}
                    </div>
                  )}

                  <button
                    type="submit"
                    disabled={loading || (selectedRoom && formData.reservation_date && formData.start_time && formData.end_time && !isSlotAvailable(selectedRoom, formData.reservation_date, formData.start_time, formData.end_time))}
                    className="w-full bg-indigo-600 text-white py-3 px-4 rounded-lg hover:bg-indigo-700 transition-colors disabled:bg-gray-400 font-medium text-lg flex items-center justify-center gap-2"
                  >
                    {loading ? (
                      <>
                        <ClockIcon className="w-5 h-5 animate-spin" />
                        Réservation en cours...
                      </>
                    ) : (
                      <>
                        <CheckCircleIcon className="w-5 h-5" />
                        Confirmer la réservation
                      </>
                    )}
                  </button>
                </form>
              )}
            </div>
          </div>
        )}

        {/* Onglet Liste des réservations */}
        {activeTab === 'reservations' && (
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-2xl font-semibold mb-6 text-gray-800">
              Liste des Réservations
            </h2>
            {reservations.length === 0 ? (
              <div className="text-center py-12 text-gray-500">
                <p className="text-lg">Aucune réservation pour le moment</p>
              </div>
            ) : (
              <div className="space-y-4">
                {reservations.map((reservation) => (
                  <div
                    key={reservation.id}
                    className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                  >
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-2">
                          <h3 className="text-lg font-bold text-indigo-900">
                            {reservation.room_name}
                          </h3>
                          <span className="px-2 py-1 bg-indigo-100 text-indigo-800 text-xs rounded-full">
                            {reservation.user_name}
                          </span>
                        </div>
                        <div className="grid grid-cols-2 gap-2 text-sm text-gray-600">
                          <p className="flex items-center gap-1">
                            <CalendarIcon className="w-4 h-4" />
                            {new Date(reservation.reservation_date).toLocaleDateString('fr-FR')}
                          </p>
                          <p className="flex items-center gap-1">
                            <ClockIcon className="w-4 h-4" />
                            {reservation.start_time} - {reservation.end_time}
                          </p>
                          {reservation.user_email && (
                            <p className="col-span-2 flex items-center gap-1">
                              <EnvelopeIcon className="w-4 h-4" />
                              {reservation.user_email}
                            </p>
                          )}
                          <p className="col-span-2 flex items-center gap-1">
                            <DocumentTextIcon className="w-4 h-4" />
                            {reservation.purpose}
                          </p>
                        </div>
                      </div>
                      <button
                        onClick={() => handleDeleteReservation(reservation.id)}
                        className="ml-4 px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors font-medium flex items-center gap-2"
                      >
                        <TrashIcon className="w-5 h-5" />
                        Annuler
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </main>
  )
}

