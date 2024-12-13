# My New Food App

**My New Food App** is a Flutter-based mobile application built with Firebase to connect buyers and sellers, focusing on selling discounted food items to reduce waste and benefit the environment. It offers robust functionality for both buyers and sellers, allowing them to interact efficiently while tracking their contributions and performance.

---

## Features

### For Sellers
- **Authentication**: Secure login and registration with Firebase authentication.
- **Product Management**: 
  - Add, edit, or delete product listings with details such as original price, discounted price, and product description.
  - Upload product images to make listings more engaging.
- **Dashboard**:
  - Track sales performance and identify best-selling products.
  - Monitor real-time statistics on the number of items sold and revenue generated.
- **Order Management**:
  - View all incoming orders in one place.
  - Update order status (e.g., Pending, In Progress, Completed).
- **Store Management**:
  - Update store details like name, operating hours, and contact information.

### For Buyers
- **Authentication**: Secure login and registration with Firebase authentication.
- **Product Discovery**:
  - Browse all available discounted products with their original prices and discounted prices.
  - View detailed product descriptions and images.
- **Order Management**:
  - Place orders easily and track their status in real-time.
  - Manage order history for quick reference.
- **Profile Management**:
  - Edit personal details and customize the user profile.
- **Environmental Impact Tracking**:
  - View personal contributions to the environment, such as the amount of food saved.

---

## Folder Structure

### `/lib`
This folder contains the main application code.
- **`/screens`**: Contains UI screens for buyers and sellers, including:
  - `seller_dashboard.dart`: A dashboard showing sales statistics and order management for sellers.
  - `product_listing.dart`: A screen to display all available products for buyers.
  - `order_tracking.dart`: A screen for buyers to track their orders.
  - `profile_screen.dart`: Profile management screen for both buyers and sellers.
- **`/models`**: Contains data models such as:
  - `Product`: Represents product details (e.g., name, price, description).
  - `Order`: Represents order details and status.
- **`/services`**: Handles backend functionality:
  - Firebase API calls for user authentication, product management, and order tracking.
- **`/widgets`**: Includes reusable components like buttons, cards, and navigation bars.

### `/assets`
Holds static resources like images and fonts.

### `/android` and `/ios`
Platform-specific code for building Android and iOS apps.

---

## Installation

### Prerequisites
- Flutter installed on your local machine. [Get started with Flutter](https://docs.flutter.dev/get-started/install).
- A configured Firebase project.

### Steps to Install
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Rany29-coder/My_new_food_app.git
   ```
2. **Navigate to the project directory**:
   ```bash
   cd My_new_food_app
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Set up Firebase**:
   - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) from your Firebase console.
   - Place them in the appropriate `/android/app` and `/ios` directories.

5. **Run the application**:
   ```bash
   flutter run
   ```

---

## How to Use

### For Sellers
1. **Sign Up**: Create a seller account by registering your store details.
2. **Manage Products**:
   - Add new products with descriptions, original prices, discounted prices, and photos.
   - Edit or remove listings as needed.
3. **Track Sales**: Use the dashboard to monitor your sales and top-performing products.
4. **Handle Orders**: Manage incoming orders and update their statuses.
5. **Edit Store Info**: Update store operating hours, name, and other details.

### For Buyers
1. **Sign Up**: Create a buyer account and log in.
2. **Browse Products**: View all available discounted items with their details.
3. **Place Orders**: Add items to your cart and proceed to checkout.
4. **Track Orders**: Monitor the status of your orders in real-time.
5. **View Impact**: Check your environmental contributions through the app.

---

## Future Enhancements
- Add push notifications for order updates and new product deals.
- Integrate payment gateways for seamless transactions.
- Introduce a loyalty rewards system for frequent buyers.
- Enable analytics for sellers to gain deeper insights into their business.

---

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact
For inquiries or collaboration, contact [Your Name] at [your.email@example.com].
```
