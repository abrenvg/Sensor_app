# Shoulder Elevation Measurement App (Flutter)

A simple Flutter application that records accelerometer and gyroscope data from a smartphone to estimate the shoulder/arm elevation angle (0° to 90°) during abduction/adduction motion. The app shows a live chart during recording, stores sessions locally, and allows CSV export for analysis.

## Features
Uses internal phone sensors (Accelerometer + Gyroscope)

Measures elevation angle using two algorithms

Algorithm 1: Accelerometer-based angle + EWMA smoothing

Algorithm 2: Accelerometer + Gyroscope via complementary filter (gyro integration + accel correction)

Start / Stop recording (recommended 10–30s)

Live continuously-updating graph of elevation angle (remains visible after stop)

Saves all recordings to a local SQLite database

View history of saved sessions

Export current or old session data as CSV (timestamp + angles)

