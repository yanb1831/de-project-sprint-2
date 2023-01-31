DROP TABLE IF EXISTS public.shipping_country_rates;
CREATE TABLE IF NOT EXISTS public.shipping_country_rates (
    shipping_country_id int GENERATED ALWAYS AS IDENTITY,
    shipping_country varchar(30) NULL,
    shipping_country_base_rate numeric(14,3) NULL,
    PRIMARY KEY (shipping_country_id)
);

DROP TABLE IF EXISTS public.shipping_agreement;
CREATE TABLE IF NOT EXISTS public.shipping_agreement (
    agreementid int NOT NULL,
    agreement_number varchar(30) NULL,
    agreement_rate numeric(14,2) NULL,
    agreement_commission numeric(14,2) NULL,
    PRIMARY KEY (agreementid)
);

DROP TABLE IF EXISTS public.shipping_transfer;
CREATE TABLE IF NOT EXISTS public.shipping_transfer (
    transfer_type_id int GENERATED ALWAYS AS IDENTITY,
    transfer_type varchar(30) NULL,
    transfer_model varchar(30) NULL,
    shipping_transfer_rate numeric(14,3) NULL,
    PRIMARY KEY (transfer_type_id)
);

DROP TABLE IF EXISTS public.shipping_info;
CREATE TABLE IF NOT EXISTS public.shipping_info (
    shippingid int NOT NULL,
    vendorid int NULL,
    payment_amount numeric(14,2) NULL,
    shipping_plan_datetime timestamp NULL,
    transfer_type_id int,
    shipping_country_id int,
    agreementid int,
    FOREIGN KEY (transfer_type_id) REFERENCES shipping_transfer (transfer_type_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (shipping_country_id) REFERENCES shipping_country_rates (shipping_country_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (agreementid) REFERENCES shipping_agreement (agreementid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

DROP TABLE IF EXISTS public.shipping_status;
CREATE TABLE IF NOT EXISTS public.shipping_status (
    shippingid int NOT NULL,
    status text NULL,
    state text NULL,
    shipping_start_fact_datetime timestamp NULL,
    shipping_end_fact_datetime timestamp NULL
);