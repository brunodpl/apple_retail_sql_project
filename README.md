The project uses five main tables:

stores: Contains information about Apple retail stores.

store_id: Unique identifier for each store.
store_name: Name of the store.
city: City where the store is located.
country: Country of the store.
category: Holds product category information.

category

category_id: Unique identifier for each product category.
category_name: Name of the category.
products: Details about Apple products.

products

product_id: Unique identifier for each product.
product_name: Name of the product.
category_id: References the category table.
launch_date: Date when the product was launched.
price: Price of the product.
sales: Stores sales transactions.

sales

sale_id: Unique identifier for each sale.
sale_date: Date of the sale.
store_id: References the store table.
product_id: References the product table.
quantity: Number of units sold.
warranty: Contains information about warranty claims.

warranty

claim_id: Unique identifier for each warranty claim.
claim_date: Date the claim was made.
sale_id: References the sales table.
repair_status: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).