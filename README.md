# Interior-Quoting-App-Flutter

## Which device/emulator type you would like the marker to test with
iphone 17 pro
ios 26.4


## A list of references used in assignment:
####flutter and firebase setup
> https://chatgpt.com/share/6a24d2a4-4448-83ec-92d0-242a4b4ef8c3
> https://www.youtube.com/watch?v=wxY3Brn0SRY
> https://fluttermapp.com
> https://medium.com/@lumeilin301/flutter-firebase-app-tutorial-part-1-get-started-95cce84939c3\n
> https://share.google/aimode/50I4sUPCGoHLWk4M5
> https://dart.dev/tools/pub/cmd/pub-outdated
> https://chatgpt.com/share/6a275fcc-8bcc-83ec-b9ab-3252571ea951
> https://www.youtube.com/watch?v=1ukSR1GRtMU&list=PL4cUxeGkcC9jLYyp2Aoh6hcWuxFDX6PBJ


####Icon serach - https://fonts.google.com/icons?selected=Material+Icons:library_add:&icon.query=add&icon.size=24&icon.color=%23e3e3e3

####development help
> all tutorial videos in KIT721 
> https://stackoverflow.com/posts/73180646/revisions
> https://pub.dev/packages/share_plus
> https://www.codecademy.com/article/rest-api-in-flutter
> https://docs.flutter.dev

## third-party plugins used
1.cupertino_icons 

Link: https://pub.dev/packages/cupertino_icons
Author: Flutter Team
Usage: Provides iOS-style icons used throughout the app for a consistent look.

2. firebase_core

Link: https://pub.dev/packages/firebase_core
Author: Flutter Team 
Usage: Initialises the Firebase app, enabling all Firebase services (Firestore, Storage, Auth) throughout the application.


3. cloud_firestore 

Link: https://pub.dev/packages/cloud_firestore
Author: Flutter Team 
Usage: Stores and retrieves all application data, including houses, rooms, and room items, from the Firebase Firestore database.


4. firebase_auth (v6.5.2)

Link: https://pub.dev/packages/firebase_auth
Author: Flutter Team
Usage: Handles user authentication for securing Firebase operations.

5. provider
   
Link: https://pub.dev/packages/provider
Author: Remi Rousselet
Usage: Serves as the state management solution for the entire app, managing HouseProvider, RoomProvider, RoomItemProvider, and ProductProvider.

6. http 

Link: https://pub.dev/packages/http
Author: Dart Team
Usage: Fetches product data from the external product API (https://utasbot.dev/kit305_2026/product) to populate the product selection screen.

7. share_plus 

Link: https://pub.dev/packages/share_plus
Author: Baseflow
Usage: Shares the itemised quote as plain text using the device's native share dialog 

8. image_picker 

Link: https://pub.dev/packages/image_picker
Author: Flutter Team (Google)
Usage: Allows users to pick images from the device's gallery when adding or editing a room.

## A list of screens app has, and a brief description of how these interrelate

#### main screen
>> Loading page - which have 4 buttons

### House list screen
>> Load - when "House List" button click from main screen

>> Include - House list with customer name has edit, delete functions, Add House button

>> Add House button is connect to **House add screen** which have reuse to edit functionality aswell

### Room list screen
>> Load - when select a **customer name** cell from **House list screen**

>> Include - Room list under selected house with customer details(has edit, delete functions), Add Room button, quote generate button

>> **Add Room** button is connect to **Room add screen** which have reuse to edit functionality aswell

>> **Get Quote** button is connect to **Quote screen** with share functionality


### Room Items List Screen
>> Load - when select a **room name** cell from **Room item list screen**

>> Include - Room item list under selected room of selected customer (has edit, delete, duplicate functions), Add Room button, Add Floor Space button

>> **Add Room** button and **Add Floor Space** is connect to **Room Item Add screen** which have reuse to edit functionality aswell

### Product Screen
>> Load - when select **Product Selection** button in **Room Item Add Screen**

>> Include - Set product to the room when select **Set** button


## custom feature --> duplicate functionality in room item
