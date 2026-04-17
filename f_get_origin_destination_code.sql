CREATE OR REPLACE FUNCTION f_get_origin_destination_code(
    in_province_id VARCHAR(20),
    in_city_id VARCHAR(20),
    in_kecamatan_id VARCHAR(20),
    in_kelurahan_id VARCHAR(20),
    in_postal_code VARCHAR(20),
    in_delivery_site VARCHAR(4)
)
RETURNS TABLE (
    origin_code VARCHAR(20),
    destination_code VARCHAR(20)
) AS $$
DECLARE
    v_origin_code VARCHAR(20);
    v_destination_code VARCHAR(20);
BEGIN
  
    SELECT 
        moj.origin_code INTO v_origin_code
    FROM 
        s_hms_site hs
    JOIN 
        m_province mp 
        ON hs.province_name = mp.province_name 
        AND mp.status = true
    JOIN 
        m_city mc 
        ON hs.city = mc.city_name 
        AND mc.status = true
    JOIN 
        ft_m_origin_code_jne moj 
        ON mp.province_id = moj.province_id 
        AND mc.city_id = moj.city_id 
        AND moj.status = true
    WHERE 
        hs.company_group = 'HSE'
        AND hs.is_setup = true
        AND hs.status = true
        AND hs.site_id = in_delivery_site
    LIMIT 1;

   
    SELECT 
        mdcj.destination_code INTO v_destination_code
    FROM 
        ft_m_destination_code_jne mdcj
    WHERE 
        mdcj.province_id = in_province_id
        AND mdcj.city_id = in_city_id
        AND mdcj.district_id = in_kecamatan_id
        AND mdcj.sub_district_id = in_kelurahan_id
        AND mdcj.postal_code = in_postal_code
        AND mdcj.status = true
    LIMIT 1;

  
    RETURN QUERY 
    SELECT v_origin_code, v_destination_code;

END;
$$ LANGUAGE plpgsql;
