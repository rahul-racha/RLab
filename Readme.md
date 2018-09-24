
# RLab - iOS application 

## Introduction
The application aims to help students and professors with an automated system that delivers the availability status of the teaching assistants in office rooms. The app removes unnecessary communication between the students and the teaching assistants (T.A's) to confirm their availability in order to help students in their coursework. It also reduces the memory load to remember the T.A's office hours.

## Devices
* RadBeacon Dot: It is an beacon that meets Apple standards (iBeacon) and advertises data using Bluetooth Low Energy.
* iPhone: Monitors the beacons availability with in the proximity of the user.

## Features
- Admins can add, edit and delete T.A's. 
- Delivers the availability status and location of the T.A. A beacon's ID can be configured to a room.
  - Presents a green dot if the T.A is at the office.
  - Presents orange dot if the T.A is involved in recitation.
  - No color when the T.A is neither at office or in recitation.
- A colored bar graph shows the T.A hours of presence at work per week (only to the admin and professor).
- Sends response to a cron job request occurring periodically to handle the availablity status with better accuracy.
- Simple notes can also be added by the T.A's.



# Requirements
* Swift 3
* iOS 9

The app is available in the App Store.
Click on the [itunes link](https://itunes.apple.com/us/app/rlab/id1239882225?mt=8) 
