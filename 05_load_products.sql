-- 실행 전 SET GLOBAL local_infile = 1; 필요 (CSV 경로는 본인 환경에 맞게 수정)
LOAD DATA LOCAL INFILE '<CSV 폴더>/olist_orders_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(product_id, @categoryname, @namelength, @descriptionlength, @photoqty, @productweight, @productlength, @productheight, @productwidth)
SET
  product_category_name      = NULLIF(@categoryname, ''),
  product_name_length             = NULLIF(@namelength, ''),
  product_description_length  = NULLIF(@descriptionlength, ''),
  product_photos_qty = NULLIF(@photoqty, ''),
  product_weight_g  = NULLIF(@productweight, ''),
  product_length_cm = NULLIF(@productlength, ''),
  product_height_cm = NULLIF(@productheight, ''),
  product_width_cm = NULLIF(@productwidth, '');