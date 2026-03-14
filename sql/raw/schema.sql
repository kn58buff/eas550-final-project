/*
Columns of the dataset.

[
    'Type', 'Days for shipping (real)', 'Days for shipment (scheduled)',
    'Benefit per order', 'Sales per customer', 'Delivery Status',
    'Late_delivery_risk', 'Category Id', 'Category Name', 'Customer City',
    'Customer Country', 'Customer Email', 'Customer Fname', 'Customer Id',
    'Customer Lname', 'Customer Password', 'Customer Segment',
    'Customer State', 'Customer Street', 'Customer Zipcode',
    'Department Id', 'Department Name', 'Latitude', 'Longitude', 'Market',
    'Order City', 'Order Country', 'Order Customer Id',
    'order date (DateOrders)', 'Order Id', 'Order Item Cardprod Id',
    'Order Item Discount', 'Order Item Discount Rate', 'Order Item Id',
    'Order Item Product Price', 'Order Item Profit Ratio',
    'Order Item Quantity', 'Sales', 'Order Item Total',
    'Order Profit Per Order', 'Order Region', 'Order State', 'Order Status',
    'Order Zipcode', 'Product Card Id', 'Product Category Id',
    'Product Description', 'Product Image', 'Product Name', 'Product Price',
    'Product Status', 'shipping date (DateOrders)', 'Shipping Mode'
]

<<<<<<< HEAD
Based on the columns.

=======
# Renamed columns: We can further think of refining these names if need.


['type', 'days_for_shipping_real', 'days_for_shipment_scheduled',
       'benefit_per_order', 'sales_per_customer', 'delivery_status',
       'late_delivery_risk', 'category_id', 'category_name', 'customer_city',
       'customer_country', 'customer_email', 'customer_fname', 'customer_id',
       'customer_lname', 'customer_password', 'customer_segment',
       'customer_state', 'customer_street', 'customer_zipcode',
       'department_id', 'department_name', 'latitude', 'longitude', 'market',
       'order_city', 'order_country', 'order_customer_id',
       'order_date_dateorders', 'order_id', 'order_item_cardprod_id',
       'order_item_discount', 'order_item_discount_rate', 'order_item_id',
       'order_item_product_price', 'order_item_profit_ratio',
       'order_item_quantity', 'sales', 'order_item_total',
       'order_profit_per_order', 'order_region', 'order_state', 'order_status',
       'order_zipcode', 'product_card_id', 'product_category_id',
       'product_description', 'product_image', 'product_name', 'product_price',
       'product_status', 'shipping_date_dateorders', 'shipping_mode'],
      dtype='str')

Based on the columns.

Basic Tables structure (51 columns total):
CUSTOMERS:
    int customer_id PK
    string first_name
    string last_name
    string email
    string segment
    string street
    string city
    string state
    string country
    string zipcode
    float latitude
    float longitude
    string market


DEPARTMENTS
    int department_id PK
    string department_name

CATEGORIES
    int category_id PK
    string category_name
    int department_id FK

PRODUCTS
    int product_id PK
    string product_name
    float product_price
    string product_status
    string product_image
    int category_id FK

ORDERS
    int order_id PK
    int customer_id FK
    date order_date
    date shipping_date
    string order_status
    string shipping_mode
    string delivery_status
    int late_delivery_risk
    string order_city
    string order_state
    string order_country
    string order_zipcode
    string order_region
    int days_shipping_real
    int days_shipping_scheduled
    float order_profit_per_order
    string payment_type


ORDER_ITEMS
    int order_item_id PK
    int order_id FK
    int product_id FK
    int quantity
    float product_price
    float discount
    float discount_rate
    float profit_ratio
    float item_total
    float sales
    float benefit_per_order
    float sales_per_customer



>>>>>>> origin/DMQL-1
Tables:

Customers:
    Customer ID, Fname, Lname, Email, Password, SegmentID, Sales per customer (?)

CustomerAddress
    Address ID, Customer ID, Customer Country, Customer State, Customer City, Customer Street, Customer Zipcode

CustomerSegment
    Segment ID, Customer Segment

Departments
    Department ID, Department Name, Latitude, Longitude

Categories
    Category ID, Category Name

Products
    Product Card ID, Product Category ID, Product Description, Product Image, Product Name, Product Price, Product Status

Markets
    MarketID, Market Name, Region iD

Orders
    Order ID, Order Customer ID, Order Item ID, Order Product ID, Order Date, Order Status,
    Order Region, Order Country, Order State, Order City, Order Zipcode,
    Profit Per Order

OrderItems
    Order Item ID, OrderID, Order Item Product Price, Order Item Profit Ratio, Order Item Quantity,
    Order Item Total, Order Item Discount, Order Item Discount Rate


ShippingModes
    Shipping Mode ID, Shipping Mode

Shipments
    ShipmentID, Order ID, Shipping Mode ID, Shipping Date, Scheduled Delivery, Actual Delivery, Delivery Status,

Regions
    RegionID, Region Name

Countries
    CountryID, CountryName, RegionID
PaymentTypes
    PaymentTypeID, PaymentTypeName



SELECT table_name
FROM information_schema.tables
WHERE table_schema='public'
*/

*/



CREATE TABLE IF NOT EXISTS departments (
    department_id INT PRIMARY KEY,
    department_name TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_price NUMERIC,
    product_status TEXT,
    product_image TEXT,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);


CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    segment TEXT,
    street TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    zipcode TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    market TEXT
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    shipping_date DATE,
    order_status TEXT,
    shipping_mode TEXT,
    delivery_status TEXT,
    late_delivery_risk INT,
    order_city TEXT,
    order_state TEXT,
    order_country TEXT,
    order_zipcode TEXT,
    order_region TEXT,
    days_shipping_real INT,
    days_shipping_scheduled INT,
    order_profit_per_order NUMERIC,
    payment_type TEXT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    product_price NUMERIC,
    discount NUMERIC,
    discount_rate NUMERIC,
    profit_ratio NUMERIC,
    item_total NUMERIC,
    sales NUMERIC,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
