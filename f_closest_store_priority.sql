CREATE OR REPLACE FUNCTION f_closest_store_priority(
    in_province_id VARCHAR
)
RETURNS TABLE (
    site_stock VARCHAR,
    site_name VARCHAR,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    store_stock VARCHAR,
    postal_code VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sdspcp.delivery_site AS site_stock, 
        hs.site_name, 
        hs.latitude::DOUBLE PRECISION, 
        hs.longitude::DOUBLE PRECISION, 
        hs.sales_office_id AS store_stock, 
        hs.postal_code
    FROM 
        s_delivery_site_priority_courier_3rd_party sdspcp
    JOIN 
        ft_s_hms_site hs 
        ON sdspcp.delivery_site = hs.site_id
        AND hs.is_setup = true
        AND hs.status = true
        AND hs.is_pickup_point = true
    WHERE 
        sdspcp.province_id = in_province_id
    ORDER BY 
        sdspcp.priority ASC;
END;
$$ LANGUAGE plpgsql;
