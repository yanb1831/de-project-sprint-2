INSERT INTO public.shipping_country_rates 
(shipping_country,shipping_country_base_rate)
SELECT DISTINCT
	   shipping_country,
	   shipping_country_base_rate
FROM public.shipping s;

INSERT INTO public.shipping_agreement
(agreementid,agreement_number,agreement_rate,agreement_commission)
SELECT DISTINCT 
	   (regexp_split_to_array(vendor_agreement_description,':'))[1]::int AS agreementid,
	   (regexp_split_to_array(vendor_agreement_description,':'))[2]::varchar(30) AS agreement_number,
	   (regexp_split_to_array(vendor_agreement_description,':'))[3]::numeric(14,2) AS agreement_rate,
	   (regexp_split_to_array(vendor_agreement_description,':'))[4]::numeric(14,2) AS agreement_commission
FROM public.shipping s;

INSERT INTO public.shipping_transfer 
(transfer_type,transfer_model,shipping_transfer_rate)
SELECT DISTINCT
	   (regexp_split_to_array(shipping_transfer_description,':'))[1]::varchar(30) AS transfer_type,
	   (regexp_split_to_array(shipping_transfer_description,':'))[2]::varchar(30) AS transfer_model,
	   shipping_transfer_rate::numeric(14,3)
FROM public.shipping s;

INSERT INTO public.shipping_info
(shippingid,vendorid,payment_amount,shipping_plan_datetime,transfer_type_id,shipping_country_id,agreementid)
WITH s AS (
	SELECT shippingid,
		   vendorid,
		   payment_amount,
		   shipping_plan_datetime,
		   shipping_country,
		   (regexp_split_to_array(shipping_transfer_description,':'))[1]::varchar(30) AS transfer_type,
		   (regexp_split_to_array(shipping_transfer_description,':'))[2]::varchar(30) AS transfer_model,
		   (regexp_split_to_array(vendor_agreement_description,':'))[1]::int AS agreementid
	FROM public.shipping)
SELECT shippingid,
	   vendorid,
	   payment_amount,
	   shipping_plan_datetime,
	   s_t.transfer_type_id,
	   s_c.shipping_country_id,
	   s_a.agreementid
FROM s
LEFT JOIN shipping_country_rates s_c ON s_c.shipping_country=s.shipping_country
LEFT JOIN shipping_transfer s_t ON s_t.transfer_type=s.transfer_type
LEFT JOIN shipping_agreement s_a ON s_a.agreementid=s.agreementid;

INSERT INTO public.shipping_status
(shippingid,status,state,shipping_start_fact_datetime,shipping_end_fact_datetime)
WITH date_ship AS (
	SELECT shippingid,
	shipping_start_fact_datetime,
	shipping_end_fact_datetime
	FROM (
		 SELECT shippingid,
		 		MIN(state_datetime) AS shipping_start_fact_datetime
		 FROM shipping
		 WHERE state = 'booked'
		 GROUP BY 1) t
	LEFT JOIN (
			   SELECT shippingid,
			   		  MAX(state_datetime) AS shipping_end_fact_datetime
		   	   FROM shipping
		   	   WHERE state = 'recieved'
		   	   GROUP BY 1) t2
	USING (shippingid))
SELECT DISTINCT 
	   s.shippingid,
	   LAST_VALUE(status) OVER(PARTITION BY s.shippingid ORDER BY s.state_datetime RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS status,
	   LAST_VALUE(state) OVER(PARTITION BY s.shippingid ORDER BY s.state_datetime RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS state,
	   shipping_start_fact_datetime,
	   shipping_end_fact_datetime
FROM shipping s
LEFT JOIN date_ship d_s ON s.shippingid =d_s.shippingid