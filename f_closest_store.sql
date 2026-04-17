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
        site_id AS site_stock, 
        s_hms_site.site_name, 
        s_hms_site.latitude, 
        s_hms_site.longitude, 
        ( 6371 * acos( cos(radians(in_latitude)) * cos(radians(s_hms_site.latitude)) * cos(radians(s_hms_site.longitude) - 
          radians(in_longitude)) + sin(radians(in_latitude)) * sin(radians(s_hms_site.latitude)) ) ) AS distance, 
        sales_office_id AS store_stock, 
        s_hms_site.postal_code
    FROM 
        s_hms_site
    WHERE 
        company_group = 'HSE'
        AND is_setup = true
        AND status = true
        AND is_pickup_point = true
    ORDER BY 
        distance ASC;
END;
$$ LANGUAGE plpgsql;
