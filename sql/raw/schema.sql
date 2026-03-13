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

*/