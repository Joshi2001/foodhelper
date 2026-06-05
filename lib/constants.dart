const appCurrencySybmbol = "₹";

enum RequestingMethods { get, post, put, delete }

const List<String> kDummyProducts = [
  "Apple",
  "Banana",
  "Cherry",
  "Date",
  "Elderberry",
  "Fig",
  "Grape",
  "Honeydew",
  "Jackfruit",
  "Kiwi",
  "Lemon",
  "Mango",
  "Nectarine",
  "Orange",
  "Papaya",
  "Quince",
  "Raspberry",
  "Strawberry",
  "Tangerine",
  "Ugli fruit",
  "Vanilla bean",
  "Watermelon",
  "Xigua melon",
  "Yellow passion fruit",
  "Zucchini",
];

const introParagraph =
    '''Welcome to Blinkit, your one-stop destination for all your grocery needs! In today's fast-paced world, we understand 
    that convenience and efficiency are key factors when it comes to shopping for 
    groceries. That's why we've created Blinkit, an innovative e-commerce grocery 
    app designed to make your shopping experience easier, faster, and more enjoyable 
    than ever before.With Blinkit, you can say goodbye to long queues and crowded 
    supermarkets. Now, you have the power to browse through an extensive range of  ''';


List kDummyCoupons = [
  {
    "headline": "Get 10% off on your first order",
    "couponCode": "NEWUSER",
    "dataPoints": [
      "Get 10% off on your first order",
      "Minimum order value: ₹500",
      "Maximum discount: ₹100",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat ₹50 off on fruits",
    "couponCode": "FRUITS50",
    "dataPoints": [
      "Flat ₹50 off on fruits",
      "Minimum order value: ₹200",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Buy 1 get 1 free on vegetables",
    "couponCode": "VEGGIES",
    "dataPoints": [
      "Buy 1 get 1 free on vegetables",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "₹100 off on groceries",
    "couponCode": "GROCERY100",
    "dataPoints": [
      "₹100 off on groceries",
      "Minimum order value: ₹1000",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat 20% off on dairy products",
    "couponCode": "DAIRY20",
    "dataPoints": [
      "Flat 20% off on dairy products",
      "Minimum order value: ₹300",
      "Maximum discount: ₹50",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "₹75 off on personal care items",
    "couponCode": "CARE75",
    "dataPoints": [
      "₹75 off on personal care items",
      "Minimum order value: ₹500",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat 15% off on household products",
    "couponCode": "HOUSE15",
    "dataPoints": [
      "Flat 15% off on household products",
      "Minimum order value: ₹400",
      "Maximum discount: ₹100",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Buy 2 get 1 free on snacks",
    "couponCode": "SNACKS",
    "dataPoints": [
      "Buy 2 get 1 free on snacks",
      "Valid till: 31st December 2021",
    ],
  },
  {
    "headline": "Flat ₹30 off on beverages",
    "couponCode": "BEV30",
    "dataPoints": [
      "Flat ₹30 off on beverages",
      "Minimum order value: ₹200",
      "Valid till: 31st December 2021",
    ],
  }
];

const kCategoriesTitles = [
 "Atta, rice & Dals",
"Breakfast,Dips & Spreads",
 "Oil & Masala's",
"Biscuits, Namkeen & Chips",
"Hot & Cold Beverages",
 "Instant&FrozenFoods"
];

const kSvgIcons = [
  "https://img.icons8.com/ios/50/wallet--v1.png",
  "https://img.icons8.com/ios/50/filled-chat.png",
  "https://img.icons8.com/dotty/80/token-card-code.png"
];
