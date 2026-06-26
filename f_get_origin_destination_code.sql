create function f_get_origin_destination_code(in_province_id text, in_city_id text, in_kecamatan_id text, in_kelurahan_id text, in_postal_code text, in_delivery_site text)
    returns TABLE(origin_code text, destination_code text)
    language plpgsql
as
$$
DECLARE
	origin_code_result TEXT;
	destination_code_result TEXT;
BEGIN
	/*
		Create On  : 2026-02-19
		Create By  : Al
		Update Log : 
			(date ; by ; description)
			- 2026-04-16 ; Al ; refactor query based on dfd logic
			- 2026-06-10 ; Al ; add new column on join mc.province_id = mp.province_id
			- 2026-06-26 ; Irsal ; province_id to province_sap_id
		Table used : 
			(database_name.{'' or ft_}+table_name+' '+initial) - database without 'ft' as prefix on table name = main database
			- pgHMSGeneral.s_hms_site hs
			- pgHMSGeneral.m_province mp
			- pgHMSGeneral.m_city mc
			- pgWarehouse.ft_m_origin_code_jne mocj
			- pgWarehouse.ft_m_destination_code_jne mdcj
	*/

	SELECT mocj.origin_code::TEXT 
	INTO origin_code_result FROM s_hms_site hs
	JOIN ft_m_origin_code_jne mocj ON hs.province_sap_id = mocj.province_sap_id AND hs.city = mocj.city AND mocj.status = TRUE
	WHERE hs.company_group = 'HSE' AND hs.is_setup = TRUE AND hs.status = TRUE AND hs.site_id = in_delivery_site 
	LIMIT 1;

	SELECT mdcj.destination_code::TEXT 
	INTO destination_code_result FROM ft_m_destination_code_jne mdcj 
	WHERE mdcj.province_id = in_province_id AND mdcj.city_id = in_city_id AND mdcj.district_id = in_kecamatan_id AND mdcj.sub_district_id = in_kelurahan_id AND mdcj.postal_code = in_postal_code AND mdcj.status = TRUE
	LIMIT 1;

	IF origin_code_result IS NOT NULL AND destination_code_result IS NOT NULL THEN
		RETURN QUERY SELECT origin_code_result::TEXT, destination_code_result::TEXT;
	END IF;

END;
$$;

alter function f_get_origin_destination_code(text, text, text, text, text, text) owner to "FST-Jamal";

