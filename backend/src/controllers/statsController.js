// backend/src/controllers/statsController.js
const Session = require('../models/sessions'); // Import the Session model
const Weapon = require('../models/weapons'); // Import the Weapon model
const mongoose = require('mongoose'); // <--- IMPORTANT: Import Mongoose

/**
 * @desc Get aggregated statistics for the authenticated user
 * @route GET /api/stats
 * @access Private (requires authentication)
 */
exports.getOverallStats = async (req, res) => {
  try {
    const userId = req.user.id;

    // Aggregate total shots fired and total sessions
    const overallStats = await Session.aggregate([
      // Match sessions belonging to the authenticated user
      // Use new mongoose.Types.ObjectId() to convert string ID to ObjectId for aggregation
      { $match: { userId: new mongoose.Types.ObjectId(userId) } },
      {
        // Group all matched documents to calculate sums for overall stats
        $group: {
          _id: null, // Group all documents for a single sum
          totalSessions: { $sum: 1 }, // Count total sessions
          totalShotsFired: { $sum: '$numberOfShotsFired' }, // Sum of shots fired
          totalHits: { $sum: '$hits' }, // Sum of hits
          totalMisses: { $sum: '$misses' } // Sum of misses
        }
      },
      {
        // Project the desired fields and calculate accuracy percentage
        $project: {
          _id: 0, // Exclude _id from the final output
          totalSessions: 1,
          totalShotsFired: 1,
          totalHits: 1,
          totalMisses: 1,
          accuracyPercentage: {
            // Calculate accuracy: (totalHits / totalShotsFired) * 100
            // Use $cond to handle division by zero if no shots were fired
            $cond: {
              if: { $gt: ['$totalShotsFired', 0] }, // If totalShotsFired > 0
              then: { $multiply: [{ $divide: ['$totalHits', '$totalShotsFired'] }, 100] }, // Calculate percentage
              else: 0 // Otherwise, accuracy is 0
            }
          }
        }
      }
    ]);

    // Aggregate shots fired per weapon
    const shotsPerWeapon = await Session.aggregate([
      // Match sessions belonging to the authenticated user
      { $match: { userId: new mongoose.Types.ObjectId(userId) } },
      {
        // Group by weapon ID to sum shots and sessions per weapon
        $group: {
          _id: '$weapon', // Group by weapon ID
          totalShots: { $sum: '$numberOfShotsFired' }, // Sum shots for this weapon
          totalSessions: { $sum: 1 } // Count sessions for this weapon
        }
      },
      {
        // Perform a left outer join with the 'weapons' collection
        // to get the weapon's name and type.
        $lookup: {
          from: 'weapons', // The name of the collection in MongoDB (usually lowercase plural of model name)
          localField: '_id', // Field from the input documents (_id of the grouped weapon)
          foreignField: '_id', // Field from the "weapons" collection
          as: 'weaponDetails' // Output array field of the joined documents
        }
      },
      {
        // Deconstructs the 'weaponDetails' array field from the input documents to output a document for each element.
        // preserveNullAndEmptyArrays: true ensures that sessions without a matching weapon are still included.
        $unwind: {
          path: '$weaponDetails',
          preserveNullAndEmptyArrays: true
        }
      },
      {
        // Reshape the output documents
        $project: {
          _id: 0, // Exclude the default _id
          weaponId: '$_id', // Rename _id to weaponId
          weaponName: '$weaponDetails.name', // Get weapon name from joined details
          weaponType: '$weaponDetails.type', // Get weapon type from joined details
          totalShots: 1, // Include totalShots
          totalSessions: 1 // Include totalSessions
        }
      },
      { $sort: { totalShots: -1 } } // Sort by total shots descending
    ]);

    // Respond with overall and per-weapon statistics
    res.json({
      overall: overallStats[0] || { totalSessions: 0, totalShotsFired: 0, totalHits: 0, totalMisses: 0, accuracyPercentage: 0 },
      shotsPerWeapon
    });

  } catch (err) {
    console.error('Error fetching statistics:', err.message);
    res.status(500).json({ message: 'Server error during statistics retrieval.' });
  }
};
