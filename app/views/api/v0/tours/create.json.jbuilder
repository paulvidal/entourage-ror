json.tour do
  json.id @tour.id
  json.type @tour.tour_type
  json.status @tour.status
  json.vehicle_type @tour.vehicle_type
end