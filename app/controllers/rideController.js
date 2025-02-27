import { prisma } from '../Server.js';
import { 
  createRideRequest, 
  acceptRide, 
  completeRide, 
  cancelRide, 
  getNearbyRides,
  // reorderRide 
} from '../services/rideService.js';

export const createRideRequestController = async (req, res) => {
  console.log("Incoming request data:", req.body);
  try {
    const { customerId, pickupLocation, dropoffLocation } = req.body;

    // Create a new ride request
    const rideRequest = await createRideRequest(customerId, pickupLocation, dropoffLocation);

    // const trip = await prisma.trip.create({
    //   data: {
    //     rideRequestId: rideRequest.id,
    //     status: 'STARTED'
    //   }
    // });

    res.status(201).json({ rideRequest });
  } catch (error) {
    res.status(500).json({ error: error.message || 'Failed to create ride request' });
  }
};

export const acceptRideController = async (req, res) => {
  try {
    const { rideId, driverId } = req.body;
    const ride = await acceptRide(rideId, driverId);
    res.status(200).json(ride);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const completeRideController = async (req, res) => {
  try {
    const { rideId, finalAmount } = req.body;
    const ride = await completeRide(rideId, finalAmount);
    res.status(200).json(ride);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const cancelRideController = async (req, res) => {
  try {
    const { tripId, canceledByType, canceledById, reason } = req.body;

    if (!tripId || !canceledByType || !canceledById) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const ride = await cancelRide(tripId, canceledByType, canceledById, reason);
    res.status(200).json(ride);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getNearbyRidesController = async (req, res) => {
  try {
    const { lat, lon, radius } = req.query;
    const rides = await getNearbyRides(
      parseFloat(lat), 
      parseFloat(lon), 
      parseFloat(radius)
    );
    res.status(200).json(rides);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const reorderRideController = async (req, res) => {
  const { previousRideId } = req.body;

  try {
    const newRideRequest = await reorderRide(previousRideId);
    res.status(201).json(newRideRequest);
  } catch (error) {
    console.error("Error reordering ride:", error.message);
    res.status(400).json({ message: "Failed to reorder ride", error: error.message });
  }
};
