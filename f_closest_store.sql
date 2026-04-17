CREATE OR REPLACE FUNCTION f_closest_store(
    in_longitude DOUBLE PRECISION,
    in_latitude DOUBLE PRECISION
)
RETURNS TABLE (
    site_stock VARCHAR,       
    site_name VARCHAR,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance DOUBLE PRECISION, 
    store_stock VARCHAR,      
    postal_code VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s_hms_site.site_id AS site_stock, 
        s_hms_site.site_name, 
        s_hms_site.latitude::DOUBLE PRECISION, 
        s_hms_site.longitude::DOUBLE PRECISION, 
        ( 6371 * acos( cos(radians(in_latitude)) * cos(radians(s_hms_site.latitude::DOUBLE PRECISION)) * cos(radians(s_hms_site.longitude::DOUBLE PRECISION) - 
          radians(in_longitude)) + sin(radians(in_latitude)) * sin(radians(s_hms_site.latitude::DOUBLE PRECISION)) ) ) AS distance, 
        s_hms_site.sales_office_id AS store_stock, 
        s_hms_site.postal_code
    FROM 
        s_hms_site
    WHERE 
        s_hms_site.company_group = 'HSE'
        AND s_hms_site.is_setup = true
        AND s_hms_site.status = true
        AND s_hms_site.is_pickup_point = true
    ORDER BY 
        distance ASC;
END;
$$ LANGUAGE plpgsql;
