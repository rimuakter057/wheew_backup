import 'dart:ui';
import 'package:flutter/material.dart';

class ParkingLocationCard extends StatelessWidget {
  const ParkingLocationCard({Key? key}) : super(key: key);

  @pragma('vm:entry-point')
  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer container styling matching the rounded corners and subtle shadow
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9F0).withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section: Title and "Electric" Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Green Park Mall',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Side Parking',
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF1E293B).withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "Electric" Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF22C55E).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.electric_bolt_rounded, // Swap with a custom plug icon if preferred
                            size: 14,
                            color: const Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Electric',
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Distance and Rating Section
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '250 m away',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFF1D4ED8), // Deep blue star as seen in UI
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottom Detailed Stats Pill Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // Left Section: Spots Info
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: const Color(0xFF1E293B).withOpacity(0.7),
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '2 spots',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider line
                      Container(
                        height: 32,
                        width: 1,
                        color: const Color(0xFF1E293B).withOpacity(0.1),
                      ),
                      // Right Section: Pricing Info
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              color: const Color(0xFF1E293B).withOpacity(0.7),
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$ 20/hr',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}