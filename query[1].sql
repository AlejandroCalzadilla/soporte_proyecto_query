use master
go
IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'Hotel_Realta')
BEGIN
    ALTER DATABASE Hotel_Realta SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END

DROP DATABASE IF EXISTS Hotel_Realta;
GO

CREATE DATABASE Hotel_Realta;
GO

USE Hotel_Realta;
GO

CREATE SCHEMA Users;
GO

CREATE SCHEMA Master;
GO

CREATE SCHEMA Hotel;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Booking;
GO

CREATE SCHEMA Resto;

GO

CREATE SCHEMA Payment;
GO

CREATE SCHEMA Purchasing;
GO

-- MODULE MASTERS --

--1
CREATE TABLE Master.regions (
  region_code int IDENTITY(1, 1),
  region_name nvarchar(35) UNIQUE NOT NULL,
  CONSTRAINT pk_region_code PRIMARY KEY(region_code)
);





CREATE TABLE Master.country (
  country_id int IDENTITY(1, 1),
  country_name nvarchar(55) UNIQUE NOT NULL,
  country_region_id int,
  CONSTRAINT pk_country_id PRIMARY KEY (country_id),
  CONSTRAINT fk_country_region_id FOREIGN KEY(country_region_id) REFERENCES Master.regions(region_code)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Master.provinces (
  prov_id int IDENTITY (1, 1),
  prov_name nvarchar(85) NOT NULL,
  prov_country_id int CONSTRAINT pk_prov_id PRIMARY KEY(prov_id),
  CONSTRAINT fk_prov_country_id FOREIGN KEY(prov_country_id) REFERENCES Master.country(country_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Master.address (
  addr_id int IDENTITY(1, 1),
  addr_line1 nvarchar(255) NOT NULL,
  addr_line2 nvarchar(255),
  addr_city NVARCHAR(25) NOT NULL,
  addr_postal_code nvarchar(5),
  addr_spatial_location NVARCHAR(100),
  addr_prov_id int,
  CONSTRAINT pk_addr_id PRIMARY KEY(addr_id),
  CONSTRAINT fk_addr_prov_id FOREIGN KEY(addr_prov_id) REFERENCES Master.provinces(prov_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

----2
CREATE TABLE Master.category_group (
  cagro_id int IDENTITY(1, 1),
  cagro_name nvarchar(25) UNIQUE NOT NULL,
  cagro_description nvarchar(255),
  cagro_type nvarchar(25) NOT NULL CHECK (cagro_type IN('category', 'service', 'facility')),
  cagro_icon nvarchar(255),
  cagro_icon_url nvarchar(255),
  CONSTRAINT pk_cagro_id PRIMARY KEY(cagro_id)
);


----3
CREATE TABLE Master.policy (
  poli_id int IDENTITY(1, 1),
  poli_name nvarchar(85) NOT NULL,
  poli_description nvarchar(255),
  CONSTRAINT pk_poli_id PRIMARY KEY(poli_id)
);




CREATE TABLE Master.policy_category_group (
  poca_poli_id int NOT NULL,
  poca_cagro_id int NOT NULL,
  CONSTRAINT fk_poca_poli_id FOREIGN KEY(poca_poli_id) REFERENCES Master.policy(poli_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT fk_poca_cagro_id FOREIGN KEY(poca_cagro_id) REFERENCES Master.category_group(cagro_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);


---4
CREATE TABLE Master.price_items (
  prit_id int IDENTITY(1, 1),
  prit_name nvarchar(55) UNIQUE NOT NULL,
  prit_price money NOT NULL,
  prit_description nvarchar(255),
  prit_type nvarchar(15) NOT NULL CHECK (prit_type IN ('SNACK', 'FACILITY', 'SOFTDRINK', 'FOOD', 'SERVICE')),
  prit_icon_url NVARCHAR(255),
  prit_modified_date datetime,
  CONSTRAINT pk_prit_id PRIMARY KEY(prit_id)
);



---5
CREATE TABLE Master.service_task (
  seta_id int IDENTITY(1, 1),
  seta_name nvarchar(85) UNIQUE NOT NULL,
  seta_seq smallint CONSTRAINT pk_set_id PRIMARY KEY(seta_id)
);


---6
CREATE TABLE Master.members (
  memb_name nvarchar(35) NOT NULL,
  memb_description nvarchar(255),
  CONSTRAINT pk_memb_name PRIMARY KEY(memb_name)
);





-- MODULE USERS	--
---7
CREATE TABLE Users.users (
  user_id int IDENTITY(1,1) NOT NULL,
  user_full_name nvarchar (85) DEFAULT 'guest' NOT NULL,
  user_type nvarchar (15) CHECK(user_type IN('T','C','I')),
  user_company_name nvarchar (255),
  user_email nvarchar(256),
  user_phone_number nvarchar (25) UNIQUE NOT NULL,
  user_modified_date datetime,
	CONSTRAINT pk_user_id PRIMARY KEY(user_id)
);

CREATE TABLE Users.user_members (
  usme_user_id int,
  usme_memb_name nvarchar(35) CHECK(usme_memb_name IN('Silver','Gold','VIP','Wizard')),
  usme_promote_date datetime,
  usme_points smallint  DEFAULT 10, 
  usme_type nvarchar(15) DEFAULT 'Expired',
	CONSTRAINT pk_usme_user_id PRIMARY KEY(usme_user_id),
	CONSTRAINT fk_usme_user_id FOREIGN KEY(usme_user_id) REFERENCES Users.users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
);



--8
CREATE TABLE Users.roles (
  role_id int IDENTITY(1,1),
  role_name nvarchar (35) NOT NULL,
	CONSTRAINT pk_role_id PRIMARY KEY(role_id)
);

CREATE TABLE Users.user_roles (
  usro_user_id int,
  usro_role_id int,
	CONSTRAINT pk_usro_user_id PRIMARY KEY(usro_user_id),
	CONSTRAINT fk_usro_user_id FOREIGN KEY (usro_user_id) REFERENCES Users.users(user_id)
	  ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_usro_role_id FOREIGN KEY (usro_role_id) REFERENCES Users.roles(role_id)
	  ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Users.user_profiles (
  uspro_id int IDENTITY(1,1),
  uspro_national_id nvarchar (20) NOT NULL,
  uspro_birth_date date NOT NULL,
  uspro_job_title nvarchar (50),
  uspro_marital_status nchar(1) CHECK(uspro_marital_status IN('M','S')),
  uspro_gender nchar(1) CHECK(uspro_gender IN('M','F')),
  uspro_addr_id int,
  uspro_user_id int,
	CONSTRAINT pk_usro_id PRIMARY KEY(uspro_id),
	CONSTRAINT fk_uspro_user_id FOREIGN KEY (uspro_user_id) REFERENCES Users.users (user_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_uspro_addr_id FOREIGN KEY (uspro_addr_id) REFERENCES Master.address (addr_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Users.bonus_points (
  ubpo_id int IDENTITY(1,1),
  ubpo_user_id int,
  ubpo_total_points smallint,
  ubpo_bonus_type nchar (1),
  ubpo_created_on datetime,
	CONSTRAINT pk_ubpo_id PRIMARY KEY(ubpo_id),
	CONSTRAINT fk_ubpo_user_id FOREIGN KEY (ubpo_user_id) REFERENCES Users.users (user_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE Users.user_password (
  uspa_user_id int IDENTITY(1,1),
  uspa_passwordHash varchar(128),
  uspa_passwordSalt varchar(10),
	CONSTRAINT pk_uspa_user_id PRIMARY KEY(uspa_user_id),
	CONSTRAINT fk_uspa_user_id FOREIGN KEY (uspa_user_id) REFERENCES users.users (user_id)
);

--MODULE HOTELS --
-- Create a new table called 'Hotels' in schema 'Hotel'
-- Drop the table if it already exists
IF OBJECT_ID('Hotel.Hotels', 'U') IS NOT NULL
DROP TABLE Hotel.Hotels
-- Create the table in the specified schema
CREATE TABLE Hotel.Hotels
(
  hotel_id int IDENTITY(1,1) NOT NULL CONSTRAINT hotel_id_pk PRIMARY KEY, -- primary key column
  hotel_name nvarchar(85) NOT NULL,
  hotel_description nvarchar(500) NULL,
  -- BEGIN UPDATE
  hotel_status BIT NOT NULL CHECK(hotel_status IN(0,1)),
  hotel_reason_status nvarchar(500) NULL,
  -- END UPDATE
  hotel_rating_star numeric(2,1) NULL,
  hotel_phonenumber nvarchar(25) NOT NULL,
  hotel_modified_date datetime NULL,
  -- Primary Key
  hotel_addr_id INT NOT NULL,
  hotel_addr_description nvarchar(500) NULL,
  -- Add this later, on production
  CONSTRAINT hotel_addr_id_fk FOREIGN KEY (hotel_addr_id) REFERENCES Master.Address(addr_id)
);

-- Create a new table called 'Hotel_Reviews' in schema 'Hotel'
-- Drop the table if it already exists
IF OBJECT_ID('Hotel.Hotel_Reviews', 'U') IS NOT NULL
DROP TABLE Hotel.Hotel_Reviews

-- Create the table in the specified schema
CREATE TABLE Hotel.Hotel_Reviews
(
  hore_id INT IDENTITY(1,1) NOT NULL CONSTRAINT hore_id_pk PRIMARY KEY, -- primary key column
  hore_user_review nvarchar(125) NOT NULL,
  hore_rating TINYINT NOT NULL CHECK(hore_rating IN(1,2,3,4,5)) DEFAULT 5,
  hore_created_on datetime NULL,
  -- FOREIGN KEY
  hore_user_id INT NOT NULL,
  hore_hotel_id INT NOT NULL,
  -- Add this later, on production
  CONSTRAINT hore_user_id_pk FOREIGN KEY (hore_user_id) REFERENCES Users.Users(user_id),
  CONSTRAINT hore_hotel_id_fk FOREIGN KEY (hore_hotel_id) REFERENCES Hotel.Hotels(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE
);


--use Hotel_Realta
--select * from Hotel.Hotels
--select *from Users.users
--select * from Hotel.Hotel_Reviews

--select *
--from Users.users
--where user_type='C'



-- Create a new table called 'Facilities' in schema 'Hotel'
-- Drop the table if it already exists
--IF OBJECT_ID('Hotel.Facilities', 'U') IS NOT NULL
--DROP TABLE Hotel.Facilities

-- Create the table in the specified schema
CREATE TABLE Hotel.Facilities
(
  faci_id INT IDENTITY(1,1) NOT NULL CONSTRAINT faci_id_pk PRIMARY KEY, -- primary key column
  faci_name nvarchar(125) NOT NULL,
  faci_description nvarchar(255) NULL,
  faci_max_number INT NULL,
  faci_measure_unit VARCHAR(15) NULL CHECK(faci_measure_unit IN('people','beds')),
  faci_room_number nvarchar(15) NOT NULL,
  faci_startdate datetime NOT NULL,
  faci_enddate datetime NOT NULL,
  faci_low_price MONEY NOT NULL,
  faci_high_price MONEY NOT NULL,
  faci_rate_price MONEY NULL,
  faci_expose_price TINYINT NOT NULL CHECK(faci_expose_price IN(1,2,3)),
  faci_discount SMALLMONEY NULL,
  faci_tax_rate SMALLMONEY NULL,
  faci_modified_date datetime NULL,
  --FOREIGN KEY
  faci_cagro_id INTEGER NOT NULL,
  faci_hotel_id INT NOT NULL,
  faci_user_id INT NOT NULL,
  -- UNIQUE ID
  CONSTRAINT faci_room_number_uq UNIQUE (faci_room_number),
  -- Add this later, on production
  CONSTRAINT faci_cagro_id_fk FOREIGN KEY (faci_cagro_id) REFERENCES Master.Category_Group(cagro_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT faci_hotel_id_fk FOREIGN KEY (faci_hotel_id) REFERENCES Hotel.Hotels(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT faci_user_id_fk FOREIGN KEY (faci_user_id) REFERENCES Users.users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

select * from Users.users u
where u.user_type = 'T'


-- Create a new table called 'Facility_Price_History' in schema 'Hotel'
-- Drop the table if it already exists
IF OBJECT_ID('Hotel.Facility_Price_History', 'U') IS NOT NULL
DROP TABLE Hotel.Facility_Price_History

-- Create the table in the specified schema
create table hotel.facility_price_history
(
  faph_id int identity(1,1) not null constraint faph_id_pk primary key, -- primary key column
  faph_startdate datetime not null,
  faph_enddate datetime not null,
  faph_low_price money not null,
  faph_high_price money not null,
  faph_rate_price money not null,
  faph_discount smallmoney null,
  faph_tax_rate smallmoney null,
  faph_modified_date datetime,
  -- foreign key
  faph_faci_id int not null,
  faph_user_id int not null,
  -- add this later, on production
  constraint faph_faci_id_fk foreign key (faph_faci_id) references hotel.facilities(faci_id) on delete cascade on update cascade,
);


-- Create a new table called 'Facility_Photos' in schema 'Hotel'
-- Drop the table if it already exists
IF OBJECT_ID('Hotel.Facility_Photos', 'U') IS NOT NULL
DROP TABLE Hotel.Facility_Photos

-- Create the table in the specified schema
CREATE TABLE Hotel.Facility_Photos
(
  fapho_id INT IDENTITY(1,1) NOT NULL CONSTRAINT fapho_id_pk PRIMARY KEY, -- primary key column
  fapho_photo_filename nvarchar(150) NULL,
  fapho_thumbnail_filename nvarchar(150) NOT NULL,
  fapho_original_filename nvarchar(150) NULL,
  fapho_file_size smallint NULL,
  fapho_file_type nvarchar(50) NULL,
  fapho_primary BIT NULL CHECK(fapho_primary IN(0,1)),
  fapho_url nvarchar(255) NULL,
  fapho_modified_date datetime,
  -- FOREIGN KEY
  fapho_faci_id INT NOT NULL,
  CONSTRAINT fapho_faci_id_fk FOREIGN KEY (fapho_faci_id) REFERENCES Hotel.Facilities(faci_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- MODULE HR --

---9
CREATE TABLE HR.job_role (
	joro_id int IDENTITY(1, 1) NOT NULL,
	joro_name nvarchar(55) NOT NULL,
	joro_modified_date datetime,
	CONSTRAINT pk_joro_id PRIMARY KEY(joro_id),
	CONSTRAINT uq_joro_name UNIQUE (joro_name)
);


--10
CREATE TABLE HR.department (
	dept_id int IDENTITY(1,1) NOT NULL,
	dept_name nvarchar(50) NOT NULL,
	dept_modified_date datetime,
	CONSTRAINT pk_dept_id PRIMARY KEY (dept_id)
);

CREATE TABLE HR.employee (
	emp_id int IDENTITY(1,1) NOT NULL,
	emp_national_id nvarchar(25) NOT NULL,
	emp_birth_date datetime NOT NULL,
	emp_marital_status nchar(1) NOT NULL,
	emp_gender nchar(1) NOT NULL,
	emp_hire_date datetime NOT NULL,
	emp_salaried_flag nchar(1) NOT NULL,
	emp_vacation_hours int,
	emp_sickleave_hourse int,
	emp_current_flag int,
	emp_emp_id int,
	emp_photo nvarchar(355),
	emp_modified_date datetime,
	emp_joro_id int NOT NULL,
	CONSTRAINT pk_emp_id PRIMARY KEY (emp_id),
	CONSTRAINT uq_emp_national_id UNIQUE (emp_national_id),
	CONSTRAINT fk_emp_joro_id FOREIGN KEY (emp_joro_id) REFERENCES HR.job_role(joro_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_emp_id FOREIGN KEY (emp_emp_id) REFERENCES hr.employee(emp_id)
);

CREATE TABLE HR.employee_pay_history (
	ephi_emp_id int NOT NULL,
	ephi_rate_change_date datetime NOT NULL,
	ephi_rate_salary money,
	ephi_pay_frequence int,
	ephi_modified_date datetime,
	CONSTRAINT pk_ephi_emp_id_ephi_rate_change_date PRIMARY KEY(ephi_emp_id, ephi_rate_change_date),
	CONSTRAINT fk_ephi_emp_id FOREIGN KEY(ephi_emp_id) REFERENCES HR.employee(emp_id) ON DELETE CASCADE ON UPDATE CASCADE
);



--11
CREATE TABLE HR.shift(
	shift_id int IDENTITY(1,1),
	shift_name nvarchar(25) NOT NULL,
	shift_start_time datetime NOT NULL,
	shift_end_time datetime NOT NULL,
	CONSTRAINT pk_shift_id PRIMARY KEY(shift_id),
	CONSTRAINT uq_shift_name UNIQUE (shift_name),
	CONSTRAINT uq_shift_start_time UNIQUE (shift_start_time),
	CONSTRAINT uq_shift_end_time UNIQUE (shift_end_time)
);

CREATE TABLE HR.employee_department_history (
	edhi_id int IDENTITY(1,1) NOT NULL,
	edhi_emp_id int NOT NULL,
	edhi_start_date datetime,
	edhi_end_date datetime,
	edhi_modified_date datetime,
	edhi_dept_id int NOT NULL,
	edhi_shift_id int NOT NULL,
	CONSTRAINT pk_edhi_id_edhi_emp_id PRIMARY KEY (edhi_id, edhi_emp_id),
	CONSTRAINT fk_edhi_emp_id FOREIGN KEY(edhi_emp_id) REFERENCES HR.employee(emp_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_shift_id FOREIGN KEY (edhi_shift_id) REFERENCES HR.shift(shift_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_edhi_dept_id FOREIGN KEY (edhi_dept_id) REFERENCES HR.department(dept_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE HR.work_orders (
	woro_id int IDENTITY(1,1),
	woro_date datetime NOT NULL,
	woro_status nvarchar(15) NOT NULL,
	woro_user_id int,
	CONSTRAINT pk_woro_id PRIMARY KEY(woro_id),
	CONSTRAINT fk_woro_user_id FOREIGN KEY(woro_user_id) REFERENCES Users.users(user_id)
)

CREATE TABLE HR.work_order_detail (
	wode_id int IDENTITY(1,1),
	wode_task_name nvarchar(255),
	wode_status nvarchar(15),
	wode_start_date datetime,
	wode_end_date datetime,
	wode_notes nvarchar(255),
	wode_emp_id int,
	wode_seta_id int,
	wode_faci_id int,
	wode_woro_id int,
	CONSTRAINT pk_wode_id PRIMARY KEY(wode_id),
	CONSTRAINT fk_woro_wode_id FOREIGN KEY(wode_woro_id) REFERENCES HR.work_orders(woro_id),
	CONSTRAINT fk_wode_emp_id FOREIGN KEY(wode_emp_id) REFERENCES HR.employee(emp_id), 
	CONSTRAINT fk_wode_seta_id FOREIGN KEY(wode_seta_id) REFERENCES Master.service_task(seta_id), 
	CONSTRAINT fk_faci_id FOREIGN KEY(wode_faci_id) REFERENCES Hotel.facilities(faci_id)
);

-- MODULE BOOKING --

--12
CREATE TABLE Booking.special_offers(
    spof_id INT IDENTITY(1,1) NOT NULL,
    spof_name NVARCHAR(105) NOT NULL,
    spof_description NVARCHAR(455) NOT NULL,
    spof_type CHAR(5) NOT NULL CHECK (spof_type IN ('T','C','I')),
    spof_discount SMALLMONEY NOT NULL,
    spof_start_date DATETIME NOT NULL,
    spof_end_date DATETIME NOT NULL,
    spof_min_qty int,
    spof_max_qty int,
    spof_modified_date DATETIME DEFAULT GETDATE()
    CONSTRAINT pk_spof_id PRIMARY KEY(spof_id)
);

CREATE TABLE Booking.booking_orders(
	boor_id INT	IDENTITY (1,1),
	boor_order_number NVARCHAR(55) NOT NULL,
	boor_order_date DATETIME DEFAULT GETDATE(),
	boor_arrival_date DATETIME,
	boor_total_room SMALLINT, --on update, count(borde_id)
	boor_total_guest SMALLINT, --input user
	boor_discount MONEY, --sum(borde_price*borde_discount)
	boor_total_tax MONEY, -- sum(borde_price*borde_tax)
	boor_total_ammount MONEY, -- sum(borde_subtotal)
	boor_down_payment MONEY, -- on update
	boor_pay_type NCHAR(2) NOT NULL, CHECK(boor_pay_type IN ('CR', 'C', 'D', 'PG')),
	boor_is_paid NCHAR(2) NOT NULL CHECK (boor_is_paid IN ('DP','P','R')),
	boor_type NVARCHAR(15) NOT NULL CHECK (boor_type IN ('T','C','I')),
	boor_cardnumber NVARCHAR(25), -- on insert on update
	boor_member_type NVARCHAR(15), -- ambil dari usme_memb_name(fk user_id)
	boor_status NVARCHAR(15) CHECK (boor_status IN ('BOOKING','CHECKIN','CHECKOUT','CLEANING','CANCELED')),
	boor_user_id INT,
	CONSTRAINT pk_boor_id PRIMARY KEY (boor_id),
	CONSTRAINT unique_boor_order_number UNIQUE (boor_order_number),
	CONSTRAINT fk_boor_user_id FOREIGN KEY (boor_user_id) REFERENCES Users.users (user_id) 
    ON DELETE CASCADE
    ON UPDATE CASCADE,
);

CREATE TABLE Booking.booking_order_detail(
	borde_boor_id INTEGER,
	borde_id INT IDENTITY (1,1) UNIQUE NOT NULL,
	borde_checkin DATETIME NOT NULL, --di input user
	borde_checkout DATETIME NOT NULL, -- di input user
	borde_adults INTEGER, -- on update
	borde_kids INTEGER, -- on update
	borde_price MONEY, -- ngambil dari faci_rate_price(fk faci_id)
	borde_extra MONEY, -- sum(boex_subtotal) dari borde_id yg sama
	borde_discount SMALLMONEY, -- faci_discount+sum(spof_discount) -> lewat soco_id
	borde_tax SMALLMONEY, -- ngambil default faci_tax_rate
	borde_subtotal AS (borde_price+(borde_price*borde_tax))-(borde_price*borde_discount),
	borde_faci_id INTEGER,
	CONSTRAINT pk_borde_id_boor_id PRIMARY KEY (borde_id, borde_boor_id),
	CONSTRAINT fk_border_boor_id FOREIGN KEY(borde_boor_id)	REFERENCES Booking.booking_orders(boor_id),
	CONSTRAINT fk_borde_faci_id FOREIGN KEY(borde_faci_id) REFERENCES Hotel.facilities(faci_id) 
		ON DELETE CASCADE 
	ON UPDATE CASCADE
);

CREATE TABLE Booking.booking_order_detail_extra(
	boex_id INT IDENTITY (1,1),
	boex_price MONEY,
	boex_qty SMALLINT,
	boex_subtotal AS boex_price*boex_qty,
	boex_measure_unit NVARCHAR(50), CHECK(boex_measure_unit IN ('people','unit','kg')),
	boex_borde_id INT,
	boex_prit_id INT
	CONSTRAINT pk_boex_id PRIMARY KEY (boex_id),
	CONSTRAINT fk_boex_borde_id FOREIGN KEY (boex_borde_id) REFERENCES Booking.booking_order_detail (borde_id) 
		ON DELETE CASCADE 
    ON UPDATE CASCADE,
	CONSTRAINT fk_boex_prit_id FOREIGN KEY (boex_prit_id) REFERENCES Master.price_items(prit_id)
		ON DELETE CASCADE 
    ON UPDATE CASCADE
)

CREATE TABLE Booking.special_offer_coupons(
    soco_id INT IDENTITY(1,1),
    soco_borde_id INT,
    soco_spof_id INT,
    CONSTRAINT pk_soco_id PRIMARY KEY(soco_id),
    CONSTRAINT fk_soco_borde_id FOREIGN KEY(soco_borde_id) REFERENCES Booking.booking_order_detail(borde_id) 
      ON DELETE CASCADE 
      ON UPDATE CASCADE,
    CONSTRAINT fk_soco_spof_id FOREIGN KEY(soco_spof_id) REFERENCES Booking.special_offers(spof_id) 
		  ON DELETE CASCADE 
      ON UPDATE CASCADE
);

CREATE TABLE Booking.user_breakfast(
    usbr_borde_id int,
    usbr_modified_date date,
    usbr_total_vacant smallint NOT NULL,
    CONSTRAINT pk_usbr_borde_id_usbr_modified_date PRIMARY KEY(usbr_borde_id,usbr_modified_date),
    CONSTRAINT fk_usbr_borde_id FOREIGN KEY(usbr_borde_id) 
		REFERENCES Booking.booking_order_detail(borde_id) 
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- MODULE RESTO --
CREATE TABLE Resto.resto_menus
(
	reme_faci_id int,
	reme_id int IDENTITY(1,1),
	reme_name nvarchar(55) NOT NULL,
	reme_description nvarchar(255),
	reme_price money NOT NULL,
	reme_status nvarchar(15) NOT NULL,
	reme_modified_date datetime,
	reme_type NVARCHAR(20),
	CONSTRAINT pk_reme_faci_id PRIMARY KEY (reme_id),
	CONSTRAINT reme_faci_id FOREIGN KEY (reme_faci_id) REFERENCES Hotel.facilities(faci_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

CREATE TABLE Resto.order_menus
(
	orme_id int IDENTITY,
	orme_order_number nvarchar (55) UNIQUE NOT NULL,
	orme_order_date datetime NOT NULL,
	orme_total_item smallint,
	--trigger
	orme_total_discount smallmoney,
	--trigger
	orme_total_amount money,
	--trigger
	orme_pay_type nchar(2) NOT NULL,
	orme_cardnumber nvarchar(25),
	orme_is_paid nchar(2),
	orme_modified_date datetime,
	orme_user_id integer,
	orme_status NVARCHAR (20),
	orme_invoice NVARCHAR (55),
	CONSTRAINT pk_orme_id PRIMARY KEY (orme_id),
	CONSTRAINT fk_orme_user_id FOREIGN KEY (orme_user_id) REFERENCES Users.users(user_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);


CREATE TABLE Resto.order_menu_detail
(
	omde_id int IDENTITY,
	orme_price money NOT NULL,
	orme_qty smallint NOT NULL,
	orme_subtotal as orme_price * orme_qty,
	orme_discount smallmoney,
	omde_orme_id integer,
	omde_reme_id integer,
	CONSTRAINT pk_omme_id PRIMARY KEY (omde_id),
	CONSTRAINT fk_omde_orme_id FOREIGN KEY (omde_orme_id) REFERENCES Resto.order_menus(orme_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
	CONSTRAINT fk_omde_reme_id FOREIGN KEY (omde_reme_id) REFERENCES Resto.resto_menus(reme_id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
);

CREATE TABLE Resto.resto_menu_photos
(
	remp_id int IDENTITY,
	remp_thumbnail_filename nvarchar (50),
	remp_photo_filename nvarchar (50),
	remp_primary BIT,
	remp_url nvarchar (255),
	remp_reme_id int,
	CONSTRAINT pk_remp_id PRIMARY KEY (remp_id),
	CONSTRAINT fk_remp_reme_id FOREIGN KEY (remp_reme_id) REFERENCES Resto.resto_menus(reme_id)
     ON DELETE CASCADE
      ON UPDATE CASCADE,
);

-- MODULE PAYMENT --


--13
CREATE TABLE Payment.entity(
	entity_id int IDENTITY(1, 1) NOT NULL,
	CONSTRAINT PK_PaymentEntityId PRIMARY KEY (entity_id) 
);

CREATE TABLE Payment.bank(
	bank_entity_id int NOT NULL,
	bank_code nvarchar(10) UNIQUE NOT NULL,
	bank_name nvarchar(55) UNIQUE NOT NULL,
	bank_modified_date datetime DEFAULT GETDATE(),
	CONSTRAINT PK_PaymentBankEntityId PRIMARY KEY(bank_entity_id),
	CONSTRAINT FK_PaymentBankEntityId FOREIGN KEY(bank_entity_id) 
		REFERENCES Payment.Entity (entity_id)
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Payment.payment_gateway(
	paga_entity_id int NOT NULL,
	paga_code nvarchar(10) UNIQUE NOT NULL,
	paga_name nvarchar(55) UNIQUE NOT NULL,
	paga_modified_date datetime DEFAULT GETDATE(),
	CONSTRAINT PK_PaymentGatewayEntityId PRIMARY KEY(paga_entity_id),
	CONSTRAINT FK_PaymentGatewayEntityId FOREIGN KEY(paga_entity_id)
		REFERENCES Payment.Entity (entity_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE Payment.user_accounts(
    usac_id int identity(1,1),
	usac_entity_id int NOT NULL,
	usac_user_id int NOT NULL,
	usac_account_number varchar(25) UNIQUE NOT NULL,
	usac_saldo money,
	usac_type nvarchar(15),
	usac_expmonth tinyint DEFAULT NULL,
	usac_expyear smallint DEFAULT NULL,
	usac_modified_date datetime DEFAULT GETDATE(),
	CONSTRAINT CK_PaymentUserAccountsType CHECK (usac_type IN ('debet', 'credit_card', 'payment')),
	CONSTRAINT PK_PaymentUserAccountsEntityId PRIMARY KEY(usac_user_id, usac_id),
	CONSTRAINT FK_PaymentUserAccountsEntityPaymentGateway_Bank FOREIGN KEY(usac_entity_id)
		REFERENCES Payment.Entity (entity_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CONSTRAINT FK_PaymentUserAccountsUserId FOREIGN KEY(usac_user_id)
		REFERENCES Users.Users (user_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE Payment.payment_transaction(
    patr_id int IDENTITY(1,1) PRIMARY KEY,
	patr_trx_number nvarchar(55) UNIQUE,
	patr_debet money default(0.0),
	patr_credit money default(0.0),
	patr_type nchar(3) NOT NULL,
	patr_note nvarchar(255),
	patr_modified_date datetime DEFAULT(GETDATE()),
	patr_order_number nvarchar(55) NULL,
	patr_source_id varchar(25) NULL,
	patr_target_id varchar(25) NULL,
	patr_trx_number_ref nvarchar(55) NULL,
	patr_user_id int,
	CONSTRAINT CK_PaymentPaymentTransactionType CHECK (patr_type IN ('TP', 'TRB', 'RPY', 'RF', 'ORM')),
	CONSTRAINT FK_PaymentPaymentTransactionUserId FOREIGN KEY (patr_user_id)
		REFERENCES Users.Users (user_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,

);

-- CREATE UNIQUE INDEX UQ_PaymentTransaction_patr_trx_number_ref
--   ON Payment.payment_transaction(patr_trx_number_ref)
--   WHERE patr_trx_number_ref IS NOT NULL

-- MODULE PURCHASING --
CREATE TABLE purchasing.vendor(
  vendor_entity_id INT,
  vendor_name NVARCHAR(55) NOT NULL,
  vendor_active BIT DEFAULT 1,
  vendor_priority BIT DEFAULT 0,
  vendor_register_date DATETIME NOT NULL DEFAULT GETDATE(),
  vendor_weburl NVARCHAR(1025),
  vendor_modified_date DATETIME NOT NULL DEFAULT GETDATE(),

  CONSTRAINT pk_vendor_entity_id PRIMARY KEY (vendor_entity_id),
  CONSTRAINT fk_vendor_entity_id FOREIGN KEY (vendor_entity_id)
	  REFERENCES payment.entity(entity_id)
	  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_vendor_priority CHECK (vendor_priority IN (0,1)),
  CONSTRAINT ck_vendor_active CHECK (vendor_active IN (0,1))
);


--14
CREATE TABLE purchasing.stocks(
  stock_id INT IDENTITY(1,1),
  stock_name NVARCHAR(255) NOT NULL,
  stock_description NVARCHAR(255),
  stock_quantity SMALLINT NOT NULL DEFAULT 0,
  stock_reorder_point SMALLINT DEFAULT 0,
  stock_used SMALLINT DEFAULT 0,
  stock_scrap SMALLINT DEFAULT 0,
  stock_price MONEY DEFAULT 0,
  stock_standar_cost MONEY DEFAULT 0,
  stock_size NVARCHAR(25),
  stock_color NVARCHAR(15),
  stock_modified_date DATETIME NOT NULL DEFAULT GETDATE(),

  CONSTRAINT pk_department_id PRIMARY KEY (stock_id)
);

CREATE TABLE purchasing.vendor_product(
  vepro_id INT IDENTITY (1,1),
  vepro_qty_stocked INT NOT NULL,
  vepro_qty_remaining INT NOT NULL,
  vepro_price MONEY NOT NULL,
  venpro_stock_id INT,
  vepro_vendor_id INT

  CONSTRAINT pk_vepro_id PRIMARY KEY (vepro_id),
  CONSTRAINT fk_venpro_stock_id FOREIGN KEY (venpro_stock_id)
	  REFERENCES purchasing.stocks(stock_id)
	  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_vepro_vendor_id FOREIGN KEY (vepro_vendor_id)
	  REFERENCES purchasing.vendor(vendor_entity_id)
	  ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE purchasing.stock_photo(
  spho_id INT IDENTITY(1,1),
  spho_thumbnail_filename NVARCHAR(50) NOT NULL,
  spho_photo_filename NVARCHAR(50) NOT NULL,
  spho_primary BIT NOT NULL DEFAULT 0,
  spho_url NVARCHAR(255) NOT NULL,
  spho_stock_id INT NOT NULL,

  CONSTRAINT pk_spho_id PRIMARY KEY (spho_id),
  CONSTRAINT fk_spho_stock_id FOREIGN KEY (spho_stock_id)
	REFERENCES purchasing.stocks(stock_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
  CONSTRAINT ck_spho_primary CHECK (spho_primary IN (0,1))
);





CREATE TABLE purchasing.purchase_order_header(
	pohe_id INT IDENTITY(1,1) NOT NULL,
	pohe_number NVARCHAR(20),
	pohe_status TINYINT DEFAULT 1,
	pohe_order_date DATETIME NOT NULL DEFAULT GETDATE(),
	pohe_subtotal MONEY,
	pohe_tax MONEY NOT NULL DEFAULT 0.1,
	pohe_total_amount AS pohe_subtotal+(pohe_tax*pohe_subtotal),
	pohe_refund MONEY DEFAULT 0,
	pohe_arrival_date DATETIME,
	pohe_pay_type NCHAR(2) NOT NULL,
	pohe_emp_id INT,
	pohe_vendor_id INT,

	CONSTRAINT pk_pohe_id PRIMARY KEY (pohe_id),
	CONSTRAINT uq_pohe_number UNIQUE (pohe_number),
	CONSTRAINT fk_pohe_emp_id FOREIGN KEY (pohe_emp_id)
	  REFERENCES hr.employee(emp_id)
	  ON DELETE CASCADE ON UPDATE CASCADE,

	CONSTRAINT fk_pohe_vendor_id FOREIGN KEY (pohe_vendor_id)
	  REFERENCES purchasing.vendor(vendor_entity_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ck_pohe_pay_type CHECK (pohe_pay_type IN('TR', 'CA')),
	CONSTRAINT ck_pohe_status CHECK (pohe_status IN(1, 2, 3, 4, 5)),
);

CREATE TABLE purchasing.purchase_order_detail (
  pode_id INT IDENTITY(1,1),
  pode_pohe_id INT,
  pode_order_qty SMALLINT NOT NULL,
  pode_price MONEY NOT NULL,
  pode_line_total AS ISNULL(pode_order_qty*pode_price, 0.00),
  pode_received_qty DECIMAL(8,2),
  pode_rejected_qty DECIMAL(8,2),
  pode_stocked_qty AS pode_received_qty - pode_rejected_qty,
  pode_modified_date DATETIME NOT NULL DEFAULT GETDATE(),
  pode_stock_id INT,

  CONSTRAINT pk_pode_id PRIMARY KEY (pode_id),
  CONSTRAINT fk_pode_pohe_id FOREIGN KEY (pode_pohe_id)
	REFERENCES purchasing.purchase_order_header(pohe_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pode_stock_id FOREIGN KEY (pode_stock_id)
	REFERENCES purchasing.stocks(stock_id)
	ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE purchasing.stock_detail (
  stod_id INT IDENTITY,
  stod_stock_id INT,
  stod_barcode_number NVARCHAR(255),
  stod_status NCHAR(2) DEFAULT 1,
  stod_notes NVARCHAR(1024),
  stod_faci_id INT,
  stod_pohe_id INT,

  CONSTRAINT pk_stod_id PRIMARY KEY (stod_id),
  CONSTRAINT uq_stod_barcode_number UNIQUE (stod_barcode_number),
  CONSTRAINT fk_stod_stock_id FOREIGN KEY (stod_stock_id)
	REFERENCES purchasing.stocks(stock_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_stod_pohe_id FOREIGN KEY (stod_pohe_id)
	REFERENCES purchasing.purchase_order_header(pohe_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_stod_faci_id FOREIGN KEY (stod_faci_id)
	REFERENCES hotel.facilities(faci_id)
	ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ck_stod_status CHECK (stod_status IN(1, 2, 3, 4))
);

CREATE TABLE purchasing.cart(
	cart_id INT IDENTITY,
	cart_emp_id INT,
	cart_vepro_id INT,
	cart_order_qty SMALLINT,
	cart_modified_date DATETIME NOT NULL DEFAULT GETDATE()

	CONSTRAINT pk_cart PRIMARY KEY (cart_id),
	CONSTRAINT fk_cart_employee FOREIGN KEY (cart_emp_id) REFERENCES hr.employee (emp_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_cart_vepro FOREIGN KEY (cart_vepro_id) REFERENCES purchasing.vendor_product(vepro_id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ck_cart_modified_date CHECK (cart_modified_date <= GETDATE())
);
go


/*------------------------------------insert master ------------------------------*/
---Modulo Master 



---1.1-regiones (continentes)  1
insert into master.regions (region_name) values ('Asia');
insert into master.regions (region_name) values ('Africa');
insert into master.regions (region_name) values ('Europa');
insert into Master.regions (region_name) values ('America');
insert into Master.regions (region_name) values ('Oceania');

go
 
--1.2.-paises   2
INSERT INTO Master.country(country_name, country_region_id) VALUES 
('Bolivia',4),
('Perú',4),
('Argentina',4),
('Colombia',4),
('Brasil',4),
('Paraguay',4),
('Uruguay',4),
('Venezuela',4),
('Chile',4),
('Ecuador',4),
('Cuba',4),
('Mexico',4);

go
 
--1.3.-departamentos   3
INSERT INTO Master.provinces(prov_name, prov_country_id) VALUES 
('Santa Cruz de la Sierra',1),
('La Paz',1),
('Cochabamba',1),
('Potosi',1),
('Pando',1),
('chuquisaca',1),
('Beni',1),
('Oruro',1),
('Tarija',1)
go



--1.4.-direcciones     4
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Scoville', 'Emmet', 'La Paz', '0000', -6.633688, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Blackbird', 'Spohn', 'Cochabamba', '0000', 55.045149, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jenifer', 'Weeping Birch', 'Potosi', '0000', -34.5954682, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westport', 'Gateway', 'Pando', '0000', 59.379366, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Caliangt', 'Havey', 'chuquisaca', '0000', -20.4827446, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bunting', 'Dawn', 'Beni', '0000', -7.1265553, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dunning', 'Scofield', 'Oruro', '0000', 13.9123164, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Barnett', 'David', 'Tarija', '0000', 41.802914, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hagan', 'Holmberg', 'La Paz', '0000', 58.5118215, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fairview', 'Schiller', 'Cochabamba', '0000', 40.761653, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartillon', 'Waywood', 'Potosi', '0000', 38.6968603, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Springs', 'Lukken', 'Pando', '0000', 41.4783577, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merchant', 'Meadow Ridge', 'chuquisaca', '0000', 40.7879444, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mariners Cove', 'Crest Line', 'Beni', '0000', 53.7002, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Longview', 'Springview', 'Oruro', '0000', 52.1741837, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Killdeer', 'Red Cloud', 'Tarija', '0000', 23.075573, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manitowish', 'Ilene', 'La Paz', '0000', -46.1022534, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('6th', 'Mendota', 'Cochabamba', '0000', 36.9923139, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Towne', 'Potosi', '0000', 43.4945737, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('South', 'Dwight', 'Pando', '0000', -30.85775, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Garrison', 'Oriole', 'chuquisaca', '0000', -6.9010133, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Homewood', 'Hudson', 'Beni', '0000', 7.38153, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Crownhardt', 'Redwing', 'Oruro', '0000', 20.585863, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nancy', 'Monument', 'Tarija', '0000', 51.6083, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Union', 'Forest', 'La Paz', '0000', 24.7762658, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Carpenter', 'Burning Wood', 'Cochabamba', '0000', 67.6955232, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Towne', 'Orin', 'Potosi', '0000', -34.4349435, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Wayridge', 'Northwestern', 'Pando', '0000', 53.0748279, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Autumn Leaf', 'chuquisaca', '0000', 10.5942421, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Myrtle', 'Pearson', 'Beni', '0000', 25.6279123, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Macpherson', 'Novick', 'Oruro', '0000', 31.59998, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagle Crest', 'Tony', 'Tarija', '0000', 24.006293, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waxwing', 'Waywood', 'La Paz', '0000', 24.848984, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maple Wood', 'Oakridge', 'Cochabamba', '0000', -9.0972502, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Quincy', 'Evergreen', 'Potosi', '0000', -0.8183228, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nelson', 'Brentwood', 'Pando', '0000', 45.0417524, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lyons', 'Caliangt', 'chuquisaca', '0000', -12.0820196, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eggendart', 'Ridgeway', 'Beni', '0000', -22.2169379, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westridge', 'Hooker', 'Oruro', '0000', -10.8996, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hanover', 'Linden', 'Tarija', '0000', 48.85917, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartillon', 'Chinook', 'La Paz', '0000', -20.3761919, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Garrison', 'Arapahoe', 'Cochabamba', '0000', 6.7826022, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kingsford', 'Dakota', 'Potosi', '0000', 40.5257819, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Coleman', 'Westerfield', 'Pando', '0000', 49.8408677, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Petterle', 'Canary', 'chuquisaca', '0000', 31.095979, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hintze', 'Eastwood', 'Beni', '0000', 12.7523556, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Transport', 'Mariners Cove', 'Oruro', '0000', 34.341574, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summer Ridge', 'Crest Line', 'Tarija', '0000', 48.5847594, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shoshone', 'Warner', 'La Paz', '0000', -8.7433, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fallview', '3rd', 'Cochabamba', '0000', 32.026097, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('3rd', 'High Crossing', 'Potosi', '0000', 44.6254349, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoard', 'Almo', 'Pando', '0000', -3.2898398, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Monterey', 'Basil', 'chuquisaca', '0000', -38.6816248, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Novick', 'Dapin', 'Beni', '0000', 10.35, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Emmet', 'Forest Dale', 'Oruro', '0000', -26.2499033, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('6th', '2nd', 'Tarija', '0000', 8.3796569, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Parkside', 'Prentice', 'La Paz', '0000', 15.228683, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maywood', 'Fair Oaks', 'Cochabamba', '0000', 40.9314367, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Anzinger', 'Potosi', '0000', -8.5424895, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rutledge', 'Bultman', 'Pando', '0000', 36.1125, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clove', 'Toban', 'chuquisaca', '0000', 15.23199, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Oriole', 'Beni', '0000', 50.2850778, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loomis', 'Elka', 'Oruro', '0000', 40.6892276, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mcguire', 'Badeau', 'Tarija', '0000', -6.9665934, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northwestern', 'Gina', 'La Paz', '0000', 40.7046234, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hintze', 'Raven', 'Cochabamba', '0000', 7.027766, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hollow Ridge', 'Bay', 'Potosi', '0000', 9.3567838, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moose', 'Marquette', 'Pando', '0000', 22.6194565, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shelley', 'Maple Wood', 'chuquisaca', '0000', -7.8808775, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talmadge', 'Sundown', 'Beni', '0000', 59.2669111, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartillon', 'Bunker Hill', 'Oruro', '0000', 15.475069, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sherman', 'Browning', 'Tarija', '0000', 37.369435, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bay', 'Maple', 'La Paz', '0000', 57.1785037, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kinsman', 'Talisman', 'Cochabamba', '0000', 50.404284, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bobwhite', 'Harbort', 'Potosi', '0000', 29.8867761, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fulton', 'Anhalt', 'Pando', '0000', -23.0821226, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warbler', 'Erie', 'chuquisaca', '0000', 49.9731106, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jana', 'Bluestem', 'Beni', '0000', -7.9954685, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Amoth', 'Bunker Hill', 'Oruro', '0000', 27.951331, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Aberg', 'Bartillon', 'Tarija', '0000', 33.955844, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Stephen', 'Upham', 'La Paz', '0000', 41.4410475, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Porter', 'Ludington', 'Cochabamba', '0000', 17.3091916, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eastlawn', 'Center', 'Potosi', '0000', 7.8143838, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lake View', 'Fair Oaks', 'Pando', '0000', 30.7298739, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spohn', 'Grover', 'chuquisaca', '0000', 53.5511779, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Debra', 'Oak Valley', 'Beni', '0000', 26.89745, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tennyson', 'Knutson', 'Oruro', '0000', -12.0560257, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jana', 'Forster', 'Tarija', '0000', 41.2221689, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Michigan', 'Lillian', 'La Paz', '0000', 41.0550723, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Montana', 'Nancy', 'Cochabamba', '0000', 38.0413984, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bonner', 'Pond', 'Potosi', '0000', 6.8117856, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manitowish', 'Mockingbird', 'Pando', '0000', -2.6382189, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vahlen', 'Kropf', 'chuquisaca', '0000', 38.828834, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summer Ridge', 'Badeau', 'Beni', '0000', 28.4233602, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mcguire', 'Portage', 'Oruro', '0000', 30.427416, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dovetail', 'Summer Ridge', 'Tarija', '0000', 6.3188032, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Homewood', 'Mayfield', 'La Paz', '0000', 28.2068263, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fordem', 'Shopko', 'Cochabamba', '0000', 35.580662, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Homewood', 'Farwell', 'Potosi', '0000', 30.701369, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marquette', 'Nevada', 'Pando', '0000', 40.3981884, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northwestern', 'Union', 'chuquisaca', '0000', 32.729683, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ruskin', 'Del Mar', 'Beni', '0000', -0.789275, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Corry', 'Dakota', 'Oruro', '0000', 27.9676537, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talmadge', 'Sullivan', 'Tarija', '0000', 17.1782591, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Wayridge', 'Kinsman', 'La Paz', '0000', 23.642114, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rusk', 'Stoughton', 'Cochabamba', '0000', 41.2717724, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Elmside', 'Starling', 'Potosi', '0000', 23.028956, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spohn', 'Acker', 'Pando', '0000', 59.1280914, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Saint Paul', 'Michigan', 'chuquisaca', '0000', -34.4786447, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summer Ridge', 'Michigan', 'Beni', '0000', 45.521777, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'David', 'Oruro', '0000', -19.6499319, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mccormick', 'Sundown', 'Tarija', '0000', 24.102499, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Garrison', 'Elka', 'La Paz', '0000', 25.0230538, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Johnson', 'Emmet', 'Cochabamba', '0000', 45.8367628, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Ridge', 'Westridge', 'Potosi', '0000', 53.695696, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hollow Ridge', 'Reindahl', 'Pando', '0000', 8.1380673, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeway', 'Killdeer', 'chuquisaca', '0000', 45.2557594, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Lunder', 'Beni', '0000', 28.162833, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('7th', 'Talmadge', 'Oruro', '0000', -8.2866081, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Continental', 'Summerview', 'Tarija', '0000', 37.005017, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morningstar', 'Pond', 'La Paz', '0000', 46.8615704, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mallard', 'Nevada', 'Cochabamba', '0000', 54.1649073, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('David', 'Briar Crest', 'Potosi', '0000', 25.8007724, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melby', 'Kenwood', 'Pando', '0000', 55.6832198, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arkansas', 'Calypso', 'chuquisaca', '0000', -7.0986081, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakewood Gardens', 'Oak Valley', 'Beni', '0000', 49.3637828, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Charing Cross', 'Charing Cross', 'Oruro', '0000', 39.128291, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anzinger', 'Forest Run', 'Tarija', '0000', 53.3004898, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jana', 'Grayhawk', 'La Paz', '0000', 24.880095, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Reinke', 'Coleman', 'Cochabamba', '0000', 30.917795, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shopko', 'Hanson', 'Potosi', '0000', -43.2623846, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Forest', 'Paget', 'Pando', '0000', 37.429832, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Miller', 'Stuart', 'chuquisaca', '0000', 13.9052519, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melvin', 'High Crossing', 'Beni', '0000', 62.471883, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Menomonie', 'Meadow Valley', 'Oruro', '0000', 61.7284389, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spaight', 'Birchwood', 'Tarija', '0000', 46.9656528, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagan', 'Fordem', 'La Paz', '0000', 55.5807611, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Delladonna', 'Wayridge', 'Cochabamba', '0000', 50.111779, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melody', 'Rockefeller', 'Potosi', '0000', 41.5256088, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rusk', 'Hudson', 'Pando', '0000', 49.4395013, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Gale', 'Summit', 'chuquisaca', '0000', 48.834578, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Logan', 'Mariners Cove', 'Beni', '0000', 41.0285386, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golden Leaf', 'Transport', 'Oruro', '0000', 48.75667, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Parkside', 'Armistice', 'Tarija', '0000', 24.066095, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Quincy', 'Bayside', 'La Paz', '0000', 27.283955, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sheridan', 'Dwight', 'Cochabamba', '0000', 31.685311, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spaight', 'Blaine', 'Potosi', '0000', 63.8223321, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ramsey', 'Hanson', 'Pando', '0000', -21.1330059, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anzinger', 'Golf', 'chuquisaca', '0000', 6.323976, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loftsgordon', 'Pine View', 'Beni', '0000', 49.65841, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Ridge', 'Crowley', 'Oruro', '0000', -6.4154, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Prairieview', 'Glendale', 'Tarija', '0000', 49.4580118, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fordem', 'Mosinee', 'La Paz', '0000', 22.0952234, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maple', 'Bobwhite', 'Cochabamba', '0000', 39.3433574, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shelley', 'Fieldstone', 'Potosi', '0000', -7.3497666, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fulton', 'Valley Edge', 'Pando', '0000', 53.1212988, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anzinger', 'Coolidge', 'chuquisaca', '0000', 56.6306408, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Crowley', 'Parkside', 'Beni', '0000', 38.8744567, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bashford', 'Becker', 'Oruro', '0000', 49.3320487, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sugar', 'Kingsford', 'Tarija', '0000', 50.24987, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lake View', 'Carioca', 'La Paz', '0000', 24.154316, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Twin Pines', 'Carey', 'Cochabamba', '0000', 14.7252329, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moulton', 'Orin', 'Potosi', '0000', 49.4992, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fuller', 'Union', 'Pando', '0000', 10.142762, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Trailsway', 'Corscot', 'chuquisaca', '0000', 48.1782952, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Namekagon', 'Stang', 'Beni', '0000', 14.565668, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waywood', 'Dawn', 'Oruro', '0000', 32.4286242, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warrior', 'Summerview', 'Tarija', '0000', 48.282193, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeview', 'Evergreen', 'La Paz', '0000', 3.61023, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('John Wall', 'Buena Vista', 'Cochabamba', '0000', 35.30385, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mendota', 'Troy', 'Potosi', '0000', 11.4385093, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Granby', 'Gale', 'Pando', '0000', -9.5961614, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American', 'Warner', 'chuquisaca', '0000', 36.608183, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buena Vista', 'Mayfield', 'Beni', '0000', -3.3186067, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hazelcrest', 'Mitchell', 'Oruro', '0000', -17.5069121, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manufacturers', 'Loftsgordon', 'Tarija', '0000', -8.4709546, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Surrey', 'Fordem', 'La Paz', '0000', -6.8641543, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chive', 'Vera', 'Cochabamba', '0000', -20.0877391, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('5th', 'School', 'Potosi', '0000', 17.292049, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Shore', 'Randy', 'Pando', '0000', 8.6800991, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chive', 'Linden', 'chuquisaca', '0000', 22.562964, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rutledge', 'Mcguire', 'Beni', '0000', 50.043163, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cambridge', 'Service', 'Oruro', '0000', 34.5215, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagan', 'Dorton', 'Tarija', '0000', 49.2513639, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dorton', 'Susan', 'La Paz', '0000', 40.404991, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Coleman', 'Sutteridge', 'Cochabamba', '0000', -8.5568557, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sundown', 'Hooker', 'Potosi', '0000', 30.031533, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Gate', 'Huxley', 'Pando', '0000', 39.4365442, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Algoma', 'Tennessee', 'chuquisaca', '0000', 27.0874564, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fair Oaks', 'Union', 'Beni', '0000', -22.4206096, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Scofield', 'Merrick', 'Oruro', '0000', -22.363303, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Swallow', 'Marcy', 'Tarija', '0000', 50.4233463, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Garrison', 'Debra', 'La Paz', '0000', 56.4010545, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hovde', 'Fair Oaks', 'Cochabamba', '0000', 54.3749589, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('1st', 'Harper', 'Potosi', '0000', 45.4372062, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lotheville', 'Ronald Regan', 'Pando', '0000', 50.2637942, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shelley', 'Meadow Ridge', 'chuquisaca', '0000', 14.5638721, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nova', 'Dwight', 'Beni', '0000', 59.4746074, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Armistice', 'Amoth', 'Oruro', '0000', 36.6950261, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roth', 'Pearson', 'Tarija', '0000', -7.5539241, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shoshone', 'Boyd', 'La Paz', '0000', -4.1615016, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pierstorff', 'Blue Bill Park', 'Cochabamba', '0000', 22.579117, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dexter', 'Luster', 'Potosi', '0000', -26.8327412, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Towne', 'Novick', 'Pando', '0000', 40.7408774, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Superior', 'Carioca', 'chuquisaca', '0000', 15.787156, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Village', 'Beni', '0000', -4.6488523, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('La Follette', 'Kinsman', 'Oruro', '0000', 35.408609, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nancy', 'Veith', 'Tarija', '0000', 41.6315023, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Di Loreto', 'Fieldstone', 'La Paz', '0000', 8.235581, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Karstens', 'Summer Ridge', 'Cochabamba', '0000', 28.579409, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Birchwood', 'Linden', 'Potosi', '0000', 36.4173244, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Canary', 'Messerschmidt', 'Pando', '0000', -20.2307033, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summerview', 'Clyde Gallagher', 'chuquisaca', '0000', 20.8381545, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', '6th', 'Beni', '0000', 41.3410168, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anthes', 'Bellgrove', 'Oruro', '0000', 5.8765279, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eggendart', 'Anthes', 'Tarija', '0000', 41.1474096, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Di Loreto', 'La Paz', '0000', 28.074649, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nelson', 'Golf View', 'Cochabamba', '0000', 53.2109968, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Green Ridge', 'Charing Cross', 'Potosi', '0000', -7.5605, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Menomonie', 'Wayridge', 'Pando', '0000', 48.6618569, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Harper', 'Magdeline', 'chuquisaca', '0000', 64.0971015, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Milwaukee', 'Mayer', 'Beni', '0000', -7.135868, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lukken', 'Vermont', 'Oruro', '0000', 32.5746598, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Katie', 'Northview', 'Tarija', '0000', 14.0285468, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Goodland', 'Texas', 'La Paz', '0000', -8.4727553, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Farragut', 'Fallview', 'Cochabamba', '0000', 5.459089, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Swallow', 'Dunning', 'Potosi', '0000', 53.3870149, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morning', 'Mcbride', 'Pando', '0000', -11.8648237, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagan', 'Haas', 'chuquisaca', '0000', 36.6484118, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Boyd', 'Darwin', 'Beni', '0000', 37.444498, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dawn', 'Hovde', 'Oruro', '0000', 30.5211502, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dwight', 'Summer Ridge', 'Tarija', '0000', 45.7646846, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mcbride', 'Donald', 'La Paz', '0000', 50.282951, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hanson', '8th', 'Cochabamba', '0000', 41.2675718, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Granby', 'Potosi', '0000', 47.747805, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cottonwood', 'Dixon', 'Pando', '0000', 38.1162631, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morningstar', 'Mitchell', 'chuquisaca', '0000', 50.5251922, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Independence', '6th', 'Beni', '0000', -6.2360264, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golden Leaf', 'Esch', 'Oruro', '0000', 3.3273599, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bellgrove', 'Scofield', 'Tarija', '0000', 30.2638032, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bluestem', 'Old Gate', 'La Paz', '0000', 14.7690395, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pierstorff', 'Lake View', 'Cochabamba', '0000', 25.015105, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Division', 'Old Gate', 'Potosi', '0000', 36.8199022, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Raven', 'Esker', 'Pando', '0000', 50.4252048, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Forest Dale', 'Mcguire', 'chuquisaca', '0000', 32.0544346, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ryan', 'Packers', 'Beni', '0000', 36.6777372, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Forest Run', 'Oruro', '0000', -21.7567077, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fremont', 'Lotheville', 'Tarija', '0000', -6.8008183, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Armistice', 'Milwaukee', 'La Paz', '0000', 22.843818, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rockefeller', 'Lindbergh', 'Cochabamba', '0000', 44.2, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spenser', 'Bowman', 'Potosi', '0000', -6.7654544, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mccormick', 'Jana', 'Pando', '0000', 34.5278415, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Acker', 'Cambridge', 'chuquisaca', '0000', 23.817974, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Veith', 'Manley', 'Beni', '0000', 28.260141, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westend', 'Blue Bill Park', 'Oruro', '0000', 37.177129, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loeprich', 'Bunker Hill', 'Tarija', '0000', 29.2083348, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Elgar', 'Brickson Park', 'La Paz', '0000', 50.2318521, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Karstens', 'Kinsman', 'Cochabamba', '0000', 21.3926035, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mendota', 'Alpine', 'Potosi', '0000', 50.6856, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Iowa', 'Buena Vista', 'Pando', '0000', -19.8428824, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lotheville', 'Ludington', 'chuquisaca', '0000', 54.256793, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dawn', 'Buena Vista', 'Beni', '0000', -8.098672, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Montana', 'Longview', 'Oruro', '0000', -22.8521905, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunbrook', 'Amoth', 'Tarija', '0000', 33.347316, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('2nd', 'Coolidge', 'La Paz', '0000', -21.4261129, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('David', 'Green', 'Cochabamba', '0000', 35.585575, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('8th', 'Welch', 'Potosi', '0000', 53.1406245, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Trailsway', 'Logan', 'Pando', '0000', 38.0117509, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Birchwood', 'Sloan', 'chuquisaca', '0000', 8.9806034, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Linden', 'Eagle Crest', 'Beni', '0000', 7.5129005, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Continental', 'Farmco', 'Oruro', '0000', 48.2629668, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Katie', 'Calypso', 'Tarija', '0000', 43.8371234, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maple', 'Meadow Vale', 'La Paz', '0000', 17.1374798, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sugar', 'Rowland', 'Cochabamba', '0000', 3.033069, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Darwin', 'Reinke', 'Potosi', '0000', -6.3621916, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jenna', 'Anzinger', 'Pando', '0000', 49.9846987, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Burning Wood', 'Hermina', 'chuquisaca', '0000', 29.2187967, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Almo', 'Jay', 'Beni', '0000', 46.3583447, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anderson', 'Thierer', 'Oruro', '0000', -7.9903162, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Service', 'Express', 'Tarija', '0000', 39.41691, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lunder', 'Briar Crest', 'La Paz', '0000', -6.3079232, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cascade', 'Monica', 'Cochabamba', '0000', 57.6995979, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rieder', 'Bowman', 'Potosi', '0000', -34.6090822, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Coolidge', 'Sycamore', 'Pando', '0000', -7.2906502, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mallory', 'Morningstar', 'chuquisaca', '0000', -14.5205297, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clemons', 'Schurz', 'Beni', '0000', -46.3478987, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridge Oak', 'Tony', 'Oruro', '0000', 47.3752386, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoard', 'Buena Vista', 'Tarija', '0000', 59.6136775, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ronald Regan', 'South', 'La Paz', '0000', -19.9245018, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dayton', 'Cottonwood', 'Cochabamba', '0000', 20.1527657, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('West', 'Fulton', 'Potosi', '0000', 32.38613, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Artisan', 'Ohio', 'Pando', '0000', -6.8089753, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jay', 'Raven', 'chuquisaca', '0000', -7.0754952, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Magdeline', 'Express', 'Beni', '0000', 50.246964, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeview', 'Straubel', 'Oruro', '0000', 44.1799774, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lighthouse Bay', 'Mosinee', 'Tarija', '0000', 30.5383451, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Goodland', 'Oneill', 'La Paz', '0000', 36.6561848, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Upham', 'Scofield', 'Cochabamba', '0000', -2.2014533, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Luster', 'Anhalt', 'Potosi', '0000', -3.4610562, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mitchell', 'Hudson', 'Pando', '0000', -21.1674808, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sauthoff', 'Jackson', 'chuquisaca', '0000', -8.498277, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lyons', 'Hooker', 'Beni', '0000', -7.337137, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sutteridge', 'Anderson', 'Oruro', '0000', 36.789796, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grasskamp', 'Eastlawn', 'Tarija', '0000', 30.807667, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fieldstone', 'Schurz', 'La Paz', '0000', 37.948461, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arrowood', 'Moulton', 'Cochabamba', '0000', -7.7013097, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Portage', 'Duke', 'Potosi', '0000', 14.602493, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clyde Gallagher', 'Oriole', 'Pando', '0000', 54.256793, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Springs', 'Esch', 'chuquisaca', '0000', 4.485011, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('La Follette', 'Lake View', 'Beni', '0000', 17.9453521, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loomis', 'Magdeline', 'Oruro', '0000', 31.651917, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Village', 'Carey', 'Tarija', '0000', 41.8822489, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('4th', 'Nelson', 'La Paz', '0000', 24.487326, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Raven', 'Cardinal', 'Cochabamba', '0000', -4.3695455, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Miller', 'Eagle Crest', 'Potosi', '0000', 50.585206, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roxbury', 'Grasskamp', 'Pando', '0000', -14.2171388, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pawling', 'Larry', 'chuquisaca', '0000', 37.363389, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golf Course', '7th', 'Beni', '0000', 23.101153, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rockefeller', 'Hooker', 'Oruro', '0000', 48.922709, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Carpenter', 'Carey', 'Tarija', '0000', 61.7242142, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fieldstone', 'Florence', 'La Paz', '0000', 43.4945737, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Evergreen', 'Warbler', 'Cochabamba', '0000', 43.8313297, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Elgar', 'Burning Wood', 'Potosi', '0000', 49.7863419, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grover', 'Carpenter', 'Pando', '0000', -25.0993621, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dapin', 'Talisman', 'chuquisaca', '0000', -2.5398781, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Corscot', 'Mendota', 'Beni', '0000', 60.0587654, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summerview', 'Clove', 'Oruro', '0000', 39.918983, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sloan', 'Eggendart', 'Tarija', '0000', -6.612633, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Center', 'Sycamore', 'La Paz', '0000', 40.210071, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Goodland', 'Donald', 'Cochabamba', '0000', 25.84791, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Fairview', 'Potosi', '0000', 51.209018, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Sycamore', 'Pando', '0000', 35.5603286, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Montana', 'Melvin', 'chuquisaca', '0000', 59.9036118, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Parkside', 'Westport', 'Beni', '0000', 53.2231057, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Huxley', 'Michigan', 'Oruro', '0000', 53.2622714, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sutherland', 'Chive', 'Tarija', '0000', 5.746649, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Hermina', 'La Paz', '0000', 28.285873, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dapin', 'Magdeline', 'Cochabamba', '0000', -3.7690648, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arizona', 'Rusk', 'Potosi', '0000', 44.439233, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anhalt', 'Hauk', 'Pando', '0000', 30.5765383, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arizona', 'Nobel', 'chuquisaca', '0000', -7.166519, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Becker', 'Memorial', 'Beni', '0000', 56.9938866, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Stoughton', 'Loeprich', 'Oruro', '0000', 18.4670158, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Shore', 'Lukken', 'Tarija', '0000', 27.630806, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('New Castle', 'Jana', 'La Paz', '0000', 41.6840477, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Victoria', 'Merry', 'Cochabamba', '0000', 36.4056598, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anderson', 'Esch', 'Potosi', '0000', 44.724837, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tennyson', 'Helena', 'Pando', '0000', -7.823074, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Gina', 'Farragut', 'chuquisaca', '0000', -30.9738956, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butterfield', 'Corben', 'Beni', '0000', -16.361238, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Reinke', 'Lindbergh', 'Oruro', '0000', 48.1251024, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dwight', 'Melvin', 'Tarija', '0000', 49.9287189, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kings', 'Comanche', 'La Paz', '0000', 53.7942932, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Sol', 'Golf View', 'Cochabamba', '0000', 59.1987737, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Riverside', 'Tomscot', 'Potosi', '0000', -4.5887697, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jenifer', 'Doe Crossing', 'Pando', '0000', 31.689906, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Corscot', 'Buena Vista', 'chuquisaca', '0000', -6.808273, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grim', 'Monument', 'Beni', '0000', 34.9128121, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mitchell', 'Cardinal', 'Oruro', '0000', 59.3582766, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoard', 'Heath', 'Tarija', '0000', 25.66145, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Miller', 'David', 'La Paz', '0000', 25.6181943, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buell', 'Alpine', 'Cochabamba', '0000', 43.785358, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warrior', 'Kim', 'Potosi', '0000', 26.7255231, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manley', 'Welch', 'Pando', '0000', 18.4180126, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butternut', 'Johnson', 'chuquisaca', '0000', 28.947331, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Reinke', 'Northview', 'Beni', '0000', 19.482042, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hollow Ridge', 'Dixon', 'Oruro', '0000', 19.4392516, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jana', 'Mosinee', 'Tarija', '0000', 11.0537247, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Esker', 'Blackbird', 'La Paz', '0000', 31.219568, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Badeau', 'Lakewood', 'Cochabamba', '0000', -6.8432007, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Esch', 'Amoth', 'Potosi', '0000', 14.93278, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Columbus', 'Graceland', 'Pando', '0000', 48.239431, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northfield', 'Mariners Cove', 'chuquisaca', '0000', 31.491169, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northwestern', 'Browning', 'Beni', '0000', 21.4981346, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunnyside', 'Ramsey', 'Oruro', '0000', 55.590397, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hollow Ridge', 'Caliangt', 'Tarija', '0000', 28.353912, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ryan', 'Memorial', 'La Paz', '0000', -6.8333257, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hollow Ridge', 'Meadow Valley', 'Cochabamba', '0000', 51.1656869, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Johnson', 'Annamark', 'Potosi', '0000', 43.273732, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shoshone', 'Brentwood', 'Pando', '0000', 58.8110301, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Messerschmidt', 'Stuart', 'chuquisaca', '0000', -9.7327, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Stone Corner', 'Hoard', 'Beni', '0000', 2.7682671, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Armistice', 'Hovde', 'Oruro', '0000', 59.418208, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Schiller', 'Southridge', 'Tarija', '0000', 36.826981, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Center', 'Alpine', 'La Paz', '0000', 31.0452345, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeview', 'Hallows', 'Cochabamba', '0000', -1.8703308, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lerdahl', 'Crowley', 'Potosi', '0000', 55.1518222, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Michigan', 'Springs', 'Pando', '0000', -7.5284147, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Trailsway', 'Jenna', 'chuquisaca', '0000', 38.35, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Browning', 'Lighthouse Bay', 'Beni', '0000', 32.061895, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sauthoff', 'Arkansas', 'Oruro', '0000', 57.5002589, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Huxley', 'Alpine', 'Tarija', '0000', -7.1743383, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Warner', 'La Paz', '0000', 9.2478, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arizona', 'Helena', 'Cochabamba', '0000', -8.8228841, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeview', 'Stone Corner', 'Potosi', '0000', -6.9136675, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Haas', 'Roxbury', 'Pando', '0000', -6.2839964, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartelt', 'Brown', 'chuquisaca', '0000', 38.7418853, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rieder', '7th', 'Beni', '0000', -34.2899021, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warner', 'Ridge Oak', 'Oruro', '0000', 39.75, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hanover', 'Petterle', 'Tarija', '0000', 53.5279846, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vahlen', 'Lyons', 'La Paz', '0000', 54.1347287, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warbler', 'Bobwhite', 'Cochabamba', '0000', 27.615202, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('3rd', 'Linden', 'Potosi', '0000', 38.87, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mendota', 'Coolidge', 'Pando', '0000', 35.90414, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sommers', 'Springview', 'chuquisaca', '0000', -19.9930478, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', 'Mockingbird', 'Beni', '0000', 37.189822, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Corscot', 'Lakeland', 'Oruro', '0000', -6.1373578, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Paget', 'Carberry', 'Tarija', '0000', 32.6717749, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Holmberg', 'Sauthoff', 'La Paz', '0000', 22.7694444, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ohio', '8th', 'Cochabamba', '0000', 30.582271, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bultman', 'Village', 'Potosi', '0000', 25.5822549, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morningstar', 'Macpherson', 'Pando', '0000', 47.92681, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cottonwood', 'Dottie', 'chuquisaca', '0000', -27.3302999, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridge Oak', 'Mosinee', 'Beni', '0000', 43.0429124, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Linden', 'Elgar', 'Oruro', '0000', 39.937881, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunnyside', 'Monument', 'Tarija', '0000', 25.558201, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Algoma', 'Marcy', 'La Paz', '0000', 25.5562935, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chive', 'Coolidge', 'Cochabamba', '0000', 11.8194472, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pearson', 'Hansons', 'Potosi', '0000', 28.55386, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Coolidge', 'Lillian', 'Pando', '0000', 40.8395426, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Schlimgen', 'Parkside', 'chuquisaca', '0000', -31.3224313, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Daystar', 'Farragut', 'Beni', '0000', 11.9170674, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westend', 'Express', 'Oruro', '0000', 32.625478, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Packers', 'Tarija', '0000', 58.5235952, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('School', 'Londonderry', 'La Paz', '0000', 30.7366196, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rusk', 'Monica', 'Cochabamba', '0000', -8.0344803, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Weeping Birch', 'Comanche', 'Potosi', '0000', 42.9107635, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bayside', 'Luster', 'Pando', '0000', 56.8564288, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Starling', 'Swallow', 'chuquisaca', '0000', 17.45685, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Doe Crossing', 'Pond', 'Beni', '0000', 9.0835262, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Goodland', 'Almo', 'Oruro', '0000', 41.7156359, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summer Ridge', 'Sachtjen', 'Tarija', '0000', 21.1881873, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pond', 'Prairie Rose', 'La Paz', '0000', -26.1011687, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Susan', 'Granby', 'Cochabamba', '0000', -6.371137, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anniversary', 'Chive', 'Potosi', '0000', 14.565668, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunfield', 'Cottonwood', 'Pando', '0000', 41.2340369, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Columbus', 'Pankratz', 'chuquisaca', '0000', 21.857958, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Texas', 'Crownhardt', 'Beni', '0000', 45.1810363, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Service', 'Roth', 'Oruro', '0000', 32.425185, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clove', 'Lawn', 'Tarija', '0000', 36.222959, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', 'Coolidge', 'La Paz', '0000', 53.5733796, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manley', 'Dahle', 'Cochabamba', '0000', 35.3209172, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bonner', 'Anthes', 'Potosi', '0000', 43.3688739, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maywood', 'Lien', 'Pando', '0000', -0.5083679, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clemons', 'Hooker', 'chuquisaca', '0000', -9.798194, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hagan', 'Dawn', 'Beni', '0000', 56.7558466, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Porter', 'Cambridge', 'Oruro', '0000', 59.989522, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakewood', 'Graedel', 'Tarija', '0000', 34.273409, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sutherland', '5th', 'La Paz', '0000', 48.9234517, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Declaration', 'Commercial', 'Cochabamba', '0000', 34.12583, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Milwaukee', 'Columbus', 'Potosi', '0000', 40.8258113, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anzinger', 'Mallard', 'Pando', '0000', -7.347756, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dahle', 'Columbus', 'chuquisaca', '0000', 15.92762, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Longview', 'Mallory', 'Beni', '0000', 31.3462005, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Birchwood', 'Loomis', 'Oruro', '0000', 38.94, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bluejay', 'Anhalt', 'Tarija', '0000', 49.9086926, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maryland', 'Mosinee', 'La Paz', '0000', -23.5307464, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mccormick', 'Jackson', 'Cochabamba', '0000', 9.3730352, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fair Oaks', 'Morning', 'Potosi', '0000', 55.6152783, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mcbride', 'Mitchell', 'Pando', '0000', 49.4118611, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nevada', 'John Wall', 'chuquisaca', '0000', 48.9046915, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Charing Cross', 'Dexter', 'Beni', '0000', 55.8437552, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waxwing', 'Aberg', 'Oruro', '0000', 50.9173381, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buhler', 'Hovde', 'Tarija', '0000', 14.7938922, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Sol', 'Lunder', 'La Paz', '0000', -7.9636675, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Oakridge', 'American', 'Cochabamba', '0000', 14.5180441, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fieldstone', 'Northwestern', 'Potosi', '0000', 42.1450502, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Lien', 'Pando', '0000', 22.3723336, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Express', 'Kim', 'chuquisaca', '0000', -16.3846284, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bultman', 'Elgar', 'Beni', '0000', 40.01833, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('High Crossing', 'Oxford', 'Oruro', '0000', 50.9346454, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Larry', 'Ludington', 'Tarija', '0000', 25.9755686, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clemons', 'Mesta', 'La Paz', '0000', -23.6509279, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Prairie Rose', 'Cherokee', 'Cochabamba', '0000', 14.5713307, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Main', 'Evergreen', 'Potosi', '0000', -7.5450262, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marcy', 'Superior', 'Pando', '0000', 35.0435187, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hanover', 'Jana', 'chuquisaca', '0000', 18.3092599, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dayton', 'Oak', 'Beni', '0000', 61.6614104, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Carioca', 'Alpine', 'Oruro', '0000', 59.8637584, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Roxbury', 'Tarija', '0000', 15.4855369, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lunder', 'Hagan', 'La Paz', '0000', -3.0412633, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Muir', 'Almo', 'Cochabamba', '0000', 39.9041999, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Forest Dale', 'Swallow', 'Potosi', '0000', 43.6296613, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cherokee', 'Pond', 'Pando', '0000', 48.8693156, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cambridge', 'Claremont', 'chuquisaca', '0000', 45.8551505, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Calypso', 'Sullivan', 'Beni', '0000', 13.5820144, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fisk', 'Judy', 'Oruro', '0000', 48.015883, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sommers', 'Dovetail', 'Tarija', '0000', 57.7313899, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fieldstone', 'Sunnyside', 'La Paz', '0000', -0.0998238, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Algoma', 'Buena Vista', 'Cochabamba', '0000', 18.907778, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('School', 'Loftsgordon', 'Potosi', '0000', 8.955271, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Charing Cross', 'Montana', 'Pando', '0000', 41.0938736, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Valley', 'Hagan', 'chuquisaca', '0000', 22.5408317, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talisman', 'Randy', 'Beni', '0000', 29.988244, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Springs', 'Michigan', 'Oruro', '0000', 12.647214, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sage', 'Butterfield', 'Tarija', '0000', 13.2836618, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Briar Crest', 'Mosinee', 'La Paz', '0000', 17.7434868, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lillian', 'Novick', 'Cochabamba', '0000', 48.816388, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eliot', 'Pankratz', 'Potosi', '0000', 17.7302207, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Brentwood', 'Brown', 'Pando', '0000', 41.305838, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Atwood', 'Ridgeview', 'chuquisaca', '0000', 40.7, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Farwell', 'Donald', 'Beni', '0000', 32.46, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Russell', 'Acker', 'Oruro', '0000', 40.5053499, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moland', 'Waywood', 'Tarija', '0000', 41.884195, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('4th', 'Kedzie', 'La Paz', '0000', -11.70753, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Sol', 'Farmco', 'Cochabamba', '0000', 30.833079, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Veith', 'Acker', 'Potosi', '0000', 11.0574624, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Independence', 'Merry', 'Pando', '0000', 60.1391526, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mosinee', 'Old Shore', 'chuquisaca', '0000', -7.316501, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summerview', 'Lakeland', 'Beni', '0000', 44.634519, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Utah', 'Dottie', 'Oruro', '0000', 25.600272, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakewood', 'Bayside', 'Tarija', '0000', 11.0978809, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('International', 'Rutledge', 'La Paz', '0000', 34.9568026, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Quincy', 'Cochabamba', '0000', 42.7590695, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nobel', 'Merry', 'Potosi', '0000', -7.7408587, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Acker', 'Union', 'Pando', '0000', 30.2638032, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Raven', 'Clyde Gallagher', 'chuquisaca', '0000', 38.004153, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Utah', 'Crest Line', 'Beni', '0000', 40.04606, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talisman', 'Pine View', 'Oruro', '0000', 7.6988579, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Comanche', 'Loftsgordon', 'Tarija', '0000', 12.6679167, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loftsgordon', 'Summerview', 'La Paz', '0000', 52.27994, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Brentwood', 'Helena', 'Cochabamba', '0000', 51.5024848, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mosinee', 'Upham', 'Potosi', '0000', 14.1305459, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Main', 'Messerschmidt', 'Pando', '0000', 30.297791, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northwestern', 'Spaight', 'chuquisaca', '0000', -5.0662102, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Paget', 'Cody', 'Beni', '0000', 32.23483, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summerview', 'Badeau', 'Oruro', '0000', -7.8533911, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lake View', 'Saint Paul', 'Tarija', '0000', 16.5762863, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Declaration', 'Merry', 'La Paz', '0000', 59.2542117, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westport', 'Lillian', 'Cochabamba', '0000', 49.9194173, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Londonderry', 'Bayside', 'Potosi', '0000', 48.8242268, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lukken', 'Linden', 'Pando', '0000', 52.4402961, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Debra', 'Lotheville', 'chuquisaca', '0000', 16.503112, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Darwin', 'Canary', 'Beni', '0000', 14.651459, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anzinger', 'John Wall', 'Oruro', '0000', 67.1355975, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American Ash', 'Sauthoff', 'Tarija', '0000', 40.5885408, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vermont', 'Mifflin', 'La Paz', '0000', 41.420018, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vahlen', 'Anzinger', 'Cochabamba', '0000', 44.904219, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nancy', 'Bluestem', 'Potosi', '0000', 39.6022749, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sloan', 'Duke', 'Pando', '0000', -7.7326298, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westport', 'Drewry', 'chuquisaca', '0000', 38.694365, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marcy', 'Harper', 'Beni', '0000', 45.0510883, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Reinke', 'Killdeer', 'Oruro', '0000', -12.8454679, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vera', 'Cherokee', 'Tarija', '0000', 42.6532844, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sundown', 'Bonner', 'La Paz', '0000', 31.263042, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fremont', 'Rockefeller', 'Cochabamba', '0000', 51.06681, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Comanche', 'Dorton', 'Potosi', '0000', 29.4374631, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Crescent Oaks', 'Novick', 'Pando', '0000', 32.224808, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Surrey', 'Redwing', 'chuquisaca', '0000', 15.6600225, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Packers', 'Parkside', 'Beni', '0000', 28.30993, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dennis', 'Dexter', 'Oruro', '0000', -16.2142869, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Dayton', 'Tarija', '0000', 36.650038, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mariners Cove', 'Utah', 'La Paz', '0000', 32.200197, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waywood', 'Artisan', 'Cochabamba', '0000', 38.63333, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nelson', 'Sachtjen', 'Potosi', '0000', 30.8337059, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sutherland', 'Almo', 'Pando', '0000', 18.8782625, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakeland', 'School', 'chuquisaca', '0000', 60.3641945, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('School', 'Butternut', 'Beni', '0000', 25.85587, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Daystar', 'Gulseth', 'Oruro', '0000', 18.9337202, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Green Ridge', 'Lyons', 'Tarija', '0000', 59.3313673, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hovde', 'Hooker', 'La Paz', '0000', -9.2957636, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ramsey', 'Johnson', 'Cochabamba', '0000', -7.4846821, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Little Fleur', 'Di Loreto', 'Potosi', '0000', 14.8108901, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kingsford', 'Bartillon', 'Pando', '0000', 41.7737809, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Troy', 'Rigney', 'chuquisaca', '0000', 41.441441, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rigney', 'Maryland', 'Beni', '0000', -18.998706, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mandrake', 'Montana', 'Oruro', '0000', 46.0972432, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eastlawn', 'Lakewood Gardens', 'Tarija', '0000', -6.361128, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Novick', 'Muir', 'La Paz', '0000', 34.5107638, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Vale', 'Clove', 'Cochabamba', '0000', 11.5218308, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Laurel', 'Marcy', 'Potosi', '0000', -6.7407026, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arkansas', 'Lotheville', 'Pando', '0000', -11.82198, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Burrows', 'Mitchell', 'chuquisaca', '0000', 14.5019116, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pepper Wood', 'Swallow', 'Beni', '0000', 42.7003378, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Green Ridge', 'Coolidge', 'Oruro', '0000', 51.1372058, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Gate', 'Muir', 'Tarija', '0000', 25.867345, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mandrake', 'Moland', 'La Paz', '0000', -7.347756, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ilene', 'Ridgeview', 'Cochabamba', '0000', 49.46634, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melby', 'Dawn', 'Potosi', '0000', 42.4353312, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marquette', 'Thackeray', 'Pando', '0000', -6.615755, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chinook', 'Truax', 'chuquisaca', '0000', -2.5482448, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Orin', 'Fulton', 'Beni', '0000', 58.6247472, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clarendon', 'Oxford', 'Oruro', '0000', 24.874839, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eastwood', 'Hanover', 'Tarija', '0000', 40.417358, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Gate', 'Leroy', 'La Paz', '0000', 38.26667, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manitowish', 'Straubel', 'Cochabamba', '0000', 29.4778934, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Mar', 'Farwell', 'Potosi', '0000', 45.697904, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Center', 'Talisman', 'Pando', '0000', -23.1072154, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pepper Wood', 'Stoughton', 'chuquisaca', '0000', 63.3767052, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moland', 'Maple Wood', 'Beni', '0000', -30.6732959, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('West', 'Utah', 'Oruro', '0000', -34.5006776, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Stoughton', 'Reinke', 'Tarija', '0000', 14.7299584, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Upham', 'Kingsford', 'La Paz', '0000', 43.6445087, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Little Fleur', 'Declaration', 'Cochabamba', '0000', -7.7169, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Saint Paul', 'Kinsman', 'Potosi', '0000', 56.9651439, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Steensland', 'Shoshone', 'Pando', '0000', 40.8806112, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kenwood', 'Browning', 'chuquisaca', '0000', 19.604951, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Knutson', 'Blue Bill Park', 'Beni', '0000', 32.320332, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nobel', 'Delladonna', 'Oruro', '0000', 17.6143085, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('School', 'Oak Valley', 'Tarija', '0000', -0.3208374, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tomscot', 'Ruskin', 'La Paz', '0000', 41.0534668, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arapahoe', 'Glacier Hill', 'Cochabamba', '0000', -7.1665502, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lien', 'Oakridge', 'Potosi', '0000', 49.5904912, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Thackeray', 'Dapin', 'Pando', '0000', -3.9257199, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Main', 'Sunbrook', 'chuquisaca', '0000', 41.0083753, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Becker', 'Prairie Rose', 'Beni', '0000', 47.171717, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jackson', 'Karstens', 'Oruro', '0000', 22.806457, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Scott', 'Johnson', 'Tarija', '0000', -23.8879561, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Longview', 'Russell', 'La Paz', '0000', 54.6, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Carey', 'Carberry', 'Cochabamba', '0000', 9.939624, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Main', 'Reinke', 'Potosi', '0000', 14.9128369, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Katie', 'East', 'Pando', '0000', 40.0380778, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Almo', 'Granby', 'chuquisaca', '0000', -19.6824436, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Heffernan', 'Hoard', 'Beni', '0000', 3.1377116, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Michigan', 'Killdeer', 'Oruro', '0000', 0.6092923, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pine View', 'Carberry', 'Tarija', '0000', 34.746611, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vidon', 'Blaine', 'La Paz', '0000', 14.5638721, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Redwing', 'Sloan', 'Cochabamba', '0000', 47.0163969, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clyde Gallagher', 'Ridgeview', 'Potosi', '0000', 31.77, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moulton', 'Donald', 'Pando', '0000', -25.0225309, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bayside', 'Summer Ridge', 'chuquisaca', '0000', 38.1861536, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sauthoff', 'Hansons', 'Beni', '0000', -34.7611766, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Havey', 'Atwood', 'Oruro', '0000', 23.83072, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manitowish', 'Old Shore', 'Tarija', '0000', 53.8191, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Drewry', 'Kings', 'La Paz', '0000', 49.4817883, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('International', 'Sycamore', 'Cochabamba', '0000', 40.288561, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Miller', 'Texas', 'Potosi', '0000', 49.9467601, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Longview', 'Talmadge', 'Pando', '0000', 34.683646, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Macpherson', 'Towne', 'chuquisaca', '0000', -7.4720926, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shopko', 'Blackbird', 'Beni', '0000', 36.7336287, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mosinee', 'Arrowood', 'Oruro', '0000', 30.5547139, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lunder', 'Holy Cross', 'Tarija', '0000', -10.07722, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Killdeer', 'Roth', 'La Paz', '0000', 46.6473105, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chive', 'Bluestem', 'Cochabamba', '0000', 41.6338439, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sage', 'Heffernan', 'Potosi', '0000', 28.848613, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American Ash', 'Lotheville', 'Pando', '0000', 29.879877, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Derek', 'Monterey', 'chuquisaca', '0000', 42.3745311, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('7th', 'La Follette', 'Beni', '0000', 40.3513253, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eliot', 'Clemons', 'Oruro', '0000', 9.9153112, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sage', 'Oriole', 'Tarija', '0000', 32.058597, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sundown', 'Northland', 'La Paz', '0000', 44.5652451, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoard', 'Melody', 'Cochabamba', '0000', 6.7810505, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merchant', 'Bartillon', 'Potosi', '0000', 50.3539812, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buena Vista', 'Bunting', 'Pando', '0000', 53.8044834, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shasta', 'Towne', 'chuquisaca', '0000', 6.8117856, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Crescent Oaks', 'Onsgard', 'Beni', '0000', 50.6503044, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Reinke', 'Oruro', '0000', 43.2496743, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Acker', 'Bellgrove', 'Tarija', '0000', 21.31, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Thackeray', 'Jay', 'La Paz', '0000', 14.3586387, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartillon', 'Eagan', 'Cochabamba', '0000', 14.6511524, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sullivan', 'Lukken', 'Potosi', '0000', 15.2286069, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manley', 'Killdeer', 'Pando', '0000', 35.5374671, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoepker', 'Fulton', 'chuquisaca', '0000', -42.7556675, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loftsgordon', 'Onsgard', 'Beni', '0000', 31.9339724, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Elka', 'Hermina', 'Oruro', '0000', 6.6402, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakewood Gardens', 'Chive', 'Tarija', '0000', 53.8037886, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golf View', 'Dottie', 'La Paz', '0000', -23.3879703, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fremont', 'Waywood', 'Cochabamba', '0000', 34.34866, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunbrook', 'Victoria', 'Potosi', '0000', 32.31, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunnyside', 'Buena Vista', 'Pando', '0000', 41.0529013, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spenser', 'School', 'chuquisaca', '0000', 39.952319, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mccormick', 'Upham', 'Beni', '0000', 37.366903, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Londonderry', 'Montana', 'Oruro', '0000', -9.8867238, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Glacier Hill', 'Ludington', 'Tarija', '0000', 20.5200611, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butterfield', 'Graedel', 'La Paz', '0000', 32.3206, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westport', 'Johnson', 'Cochabamba', '0000', 49.5936213, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Monica', 'David', 'Potosi', '0000', 39.1372748, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', 'Banding', 'Pando', '0000', 51.78914, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grasskamp', '3rd', 'chuquisaca', '0000', -8.681907, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jenifer', 'Warrior', 'Beni', '0000', 30.0746, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chive', 'Oriole', 'Oruro', '0000', 42.2098979, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grasskamp', 'Cardinal', 'Tarija', '0000', 29.423417, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoffman', 'Old Gate', 'La Paz', '0000', 22.1484928, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hauk', 'Linden', 'Cochabamba', '0000', 5.1886762, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pond', 'Lighthouse Bay', 'Potosi', '0000', 49.6284572, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shoshone', 'Evergreen', 'Pando', '0000', 48.2735736, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Swallow', 'Karstens', 'chuquisaca', '0000', 31.8840886, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manley', 'Talisman', 'Beni', '0000', 24.1092009, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Myrtle', 'Kensington', 'Oruro', '0000', 51.5489435, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('8th', 'Derek', 'Tarija', '0000', 45.674028, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Valley Edge', 'Little Fleur', 'La Paz', '0000', 32.955581, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fairview', 'Oxford', 'Cochabamba', '0000', 35.640089, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morning', 'Dwight', 'Potosi', '0000', 41.09028, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Crescent Oaks', 'Dottie', 'Pando', '0000', 6.8907086, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', 'Atwood', 'chuquisaca', '0000', 38.5537924, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Oak Valley', 'Jenifer', 'Beni', '0000', 49.7371648, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mosinee', 'Fuller', 'Oruro', '0000', -6.8903936, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Brown', 'Arizona', 'Tarija', '0000', 39.989836, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fair Oaks', 'Golf', 'La Paz', '0000', 17.76999, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('West', '8th', 'Cochabamba', '0000', -24.5997626, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buell', 'Schmedeman', 'Potosi', '0000', 38.7188171, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roth', '3rd', 'Pando', '0000', 25.6538807, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maple', 'Mayfield', 'chuquisaca', '0000', 33.6042793, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Texas', 'Rockefeller', 'Beni', '0000', 60.0203894, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cottonwood', 'Dwight', 'Oruro', '0000', -5.14445, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoffman', 'Harbort', 'Tarija', '0000', 31.207751, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Burning Wood', 'Shasta', 'La Paz', '0000', 39.5676563, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Daystar', 'Weeping Birch', 'Cochabamba', '0000', 50.6655892, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Susan', 'Oak', 'Potosi', '0000', 13.7279858, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hansons', 'Lakewood', 'Pando', '0000', 18.504589, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Thierer', 'Hermina', 'chuquisaca', '0000', 30.5312657, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bluejay', 'Forster', 'Beni', '0000', 42.583016, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Redwing', 'Kings', 'Oruro', '0000', 27.8169, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Sol', 'Portage', 'Tarija', '0000', 48.9270449, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rigney', 'Carpenter', 'La Paz', '0000', -24.2449065, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Little Fleur', 'Cordelia', 'Cochabamba', '0000', -15.7994139, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Messerschmidt', 'Acker', 'Potosi', '0000', 50.4034992, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sherman', 'Rockefeller', 'Pando', '0000', 33.917649, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Russell', 'Mccormick', 'chuquisaca', '0000', 31.917522, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Gina', 'Boyd', 'Beni', '0000', 12.0687, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Russell', 'Nevada', 'Oruro', '0000', 36.628305, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Twin Pines', '4th', 'Tarija', '0000', 14.6843598, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Longview', 'Prairie Rose', 'La Paz', '0000', 49.6308644, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butternut', 'Maple Wood', 'Cochabamba', '0000', 39.7968818, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Susan', 'Stuart', 'Potosi', '0000', 35.295007, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American', 'Killdeer', 'Pando', '0000', 40.7392836, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northfield', 'Armistice', 'chuquisaca', '0000', 53.6179245, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ludington', 'Ilene', 'Beni', '0000', 33.708276, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eliot', 'Doe Crossing', 'Oruro', '0000', 36.691279, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roth', 'Walton', 'Tarija', '0000', 63.7388395, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tony', 'Dottie', 'La Paz', '0000', 30.352134, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anniversary', 'Granby', 'Cochabamba', '0000', 55.7756358, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Carberry', 'Graceland', 'Potosi', '0000', 10.1684514, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Messerschmidt', 'Pando', '0000', -9.1930089, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Helena', 'Village Green', 'chuquisaca', '0000', 35.87616, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Colorado', 'Katie', 'Beni', '0000', 18.3419004, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pierstorff', 'Beilfuss', 'Oruro', '0000', 11.2210043, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talmadge', 'Carpenter', 'Tarija', '0000', 13.0883907, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Florence', 'Bellgrove', 'La Paz', '0000', 26.790544, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mosinee', 'Mosinee', 'Cochabamba', '0000', -1.259553, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Twin Pines', 'Sommers', 'Potosi', '0000', 57.5067967, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cottonwood', 'Hanson', 'Pando', '0000', -9.9831, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pierstorff', 'Bellgrove', 'chuquisaca', '0000', 28.564189, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Independence', 'East', 'Beni', '0000', -7.5450262, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ilene', 'Twin Pines', 'Oruro', '0000', 46.3856393, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jackson', 'Texas', 'Tarija', '0000', 33.54832, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westerfield', 'Muir', 'La Paz', '0000', 6.477755, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridgeway', 'Derek', 'Cochabamba', '0000', 7.3275252, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Jay', 'Holy Cross', 'Potosi', '0000', 24.848984, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Namekagon', 'Talisman', 'Pando', '0000', 14.233333, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Claremont', 'Memorial', 'chuquisaca', '0000', -6.9947862, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Truax', 'Hayes', 'Beni', '0000', -8.0060188, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Vale', 'Daystar', 'Oruro', '0000', 51.9601912, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Michigan', 'Bunker Hill', 'Tarija', '0000', 34.4740361, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Barby', 'Summer Ridge', 'La Paz', '0000', 35.8037979, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dottie', 'Mosinee', 'Cochabamba', '0000', 51.6571864, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Katie', 'Kenwood', 'Potosi', '0000', 33.195993, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Swallow', 'Jenna', 'Pando', '0000', 25.2743983, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Quincy', 'Schmedeman', 'chuquisaca', '0000', 27.69965, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Northridge', 'Ryan', 'Beni', '0000', 38.652683, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Starling', 'Elmside', 'Oruro', '0000', -1.8703308, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Glendale', 'Oak', 'Tarija', '0000', 19.5797297, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Eagan', 'La Paz', '0000', -7.9110809, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Autumn Leaf', 'Harbort', 'Cochabamba', '0000', 40.5784827, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Vermont', 'Havey', 'Potosi', '0000', 62.4232512, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Forster', 'Crowley', 'Pando', '0000', -31.4561755, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lindbergh', 'Toban', 'chuquisaca', '0000', 43.15, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Drewry', 'Merry', 'Beni', '0000', 41.2357155, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Merry', 'Lakewood', 'Oruro', '0000', 21.428436, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Talmadge', 'Cardinal', 'Tarija', '0000', 49.794945, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ronald Regan', '4th', 'La Paz', '0000', 33.612843, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spaight', 'Truax', 'Cochabamba', '0000', 29.053409, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Leroy', 'Manufacturers', 'Potosi', '0000', 38.9200512, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sauthoff', 'Mitchell', 'Pando', '0000', 24.066095, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American', 'Harper', 'chuquisaca', '0000', 19.2540302, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cardinal', 'Swallow', 'Beni', '0000', 30.20003, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Larry', 'Johnson', 'Oruro', '0000', 31.2122278, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Banding', 'Hauk', 'Tarija', '0000', 43.4945737, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ridge Oak', 'Forest Dale', 'La Paz', '0000', 36.5888732, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Morningstar', 'Cochabamba', '0000', 11.7863324, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Main', 'Potosi', '0000', 32.42465, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pierstorff', 'Moland', 'Pando', '0000', 52.3518344, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Garrison', 'Anzinger', 'chuquisaca', '0000', 34.7188616, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('3rd', 'Miller', 'Beni', '0000', -17.5706623, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tennyson', 'Commercial', 'Oruro', '0000', 2.100305, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sachtjen', 'Sherman', 'Tarija', '0000', 10.4477737, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roxbury', 'Merry', 'La Paz', '0000', 64.6789618, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Barnett', 'Prairie Rose', 'Cochabamba', '0000', -34.7682125, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Union', 'Potosi', '0000', 41.811979, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pawling', 'Pearson', 'Pando', '0000', 7.619032, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Columbus', 'Atwood', 'chuquisaca', '0000', 42.8983715, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bashford', 'Grover', 'Beni', '0000', -11.4260053, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Meadow Ridge', 'Thompson', 'Oruro', '0000', 21.0598649, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sullivan', 'Raven', 'Tarija', '0000', -6.8392705, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Kinsman', 'Hansons', 'La Paz', '0000', 16.7445704, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fremont', 'Carpenter', 'Cochabamba', '0000', 10.7424589, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Debra', 'Doe Crossing', 'Potosi', '0000', 39.3433574, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bashford', 'Charing Cross', 'Pando', '0000', 9.939624, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Village', 'Sunbrook', 'chuquisaca', '0000', 10.431916, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eggendart', 'Mayfield', 'Beni', '0000', 43.6953508, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eggendart', 'Forest Dale', 'Oruro', '0000', -17.7178133, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('High Crossing', 'Manitowish', 'Tarija', '0000', 42.0387882, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hoard', 'Chive', 'La Paz', '0000', 38.682014, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dunning', 'Darwin', 'Cochabamba', '0000', -11.4260053, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Darwin', 'Tomscot', 'Potosi', '0000', 50.246964, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Boyd', 'Namekagon', 'Pando', '0000', 6.9130451, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Beilfuss', 'Graedel', 'chuquisaca', '0000', 48.9361342, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('American Ash', 'Tennyson', 'Beni', '0000', 12.4544798, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Laurel', 'Mifflin', 'Oruro', '0000', 10.6713871, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Artisan', 'Hanson', 'Tarija', '0000', -1.2545772, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Summer Ridge', 'Independence', 'La Paz', '0000', 51.2250373, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shopko', 'Wayridge', 'Cochabamba', '0000', 3.9671435, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Roth', 'Shoshone', 'Potosi', '0000', 28.880867, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Scott', 'Gateway', 'Pando', '0000', 14.6031411, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Steensland', 'Caliangt', 'chuquisaca', '0000', 42.0813751, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Elgar', 'Brickson Park', 'Beni', '0000', 55.6817886, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Memorial', 'Northwestern', 'Oruro', '0000', 29.956858, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hazelcrest', 'Kropf', 'Tarija', '0000', 41.1731486, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Warner', 'Dahle', 'La Paz', '0000', 23.9179637, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Algoma', 'American Ash', 'Cochabamba', '0000', 22.579117, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Macpherson', 'Lindbergh', 'Potosi', '0000', 38.7, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Prairie Rose', 'Namekagon', 'Pando', '0000', 28.846966, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Truax', 'Becker', 'chuquisaca', '0000', 31.364042, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bashford', 'Kensington', 'Beni', '0000', 24.64995, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bultman', 'Farmco', 'Oruro', '0000', -7.2284727, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Messerschmidt', 'Roxbury', 'Tarija', '0000', -8.5614257, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Larry', 'Derek', 'La Paz', '0000', 43.981544, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bluestem', 'Hagan', 'Cochabamba', '0000', 10.6231047, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bunker Hill', 'Schurz', 'Potosi', '0000', 52.3863062, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Granby', 'Eagan', 'Pando', '0000', -23.8778461, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dorton', 'Rigney', 'chuquisaca', '0000', 42.0387882, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Schiller', 'Homewood', 'Beni', '0000', 50.3919, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Steensland', 'Delladonna', 'Oruro', '0000', 52.7301035, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ronald Regan', '3rd', 'Tarija', '0000', 32.6546275, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rutledge', 'Northridge', 'La Paz', '0000', 16.8907872, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Spaight', 'Crowley', 'Cochabamba', '0000', 48.6277459, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fuller', 'Dayton', 'Potosi', '0000', -42.7556675, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nobel', 'Starling', 'Pando', '0000', -20.1127536, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Burrows', 'Grasskamp', 'chuquisaca', '0000', 42.2971095, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunbrook', 'Kensington', 'Beni', '0000', -9.503288, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hazelcrest', 'Esker', 'Oruro', '0000', 30.3776024, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Jenna', 'Tarija', '0000', -6.2315975, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sutteridge', 'Northfield', 'La Paz', '0000', 13.7761367, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fallview', 'Welch', 'Cochabamba', '0000', 28.0154753, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Delaware', 'Oxford', 'Potosi', '0000', -28.3833642, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('1st', 'Carberry', 'Pando', '0000', -5.5850343, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Doe Crossing', 'Mariners Cove', 'chuquisaca', '0000', -8.4513, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ramsey', 'Miller', 'Beni', '0000', 48.6277459, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('4th', 'Walton', 'Oruro', '0000', 40.9392676, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Del Sol', '2nd', 'Tarija', '0000', -6.361128, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Valley Edge', 'Fairview', 'La Paz', '0000', 44.5209494, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Victoria', 'South', 'Cochabamba', '0000', 9.1707145, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grim', 'Roth', 'Potosi', '0000', -31.3366412, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pond', 'Laurel', 'Pando', '0000', 10.8991156, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Florence', '1st', 'chuquisaca', '0000', 16.7054663, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hooker', 'Nevada', 'Beni', '0000', 16.004175, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Menomonie', 'Lakewood', 'Oruro', '0000', 60.134938, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Towne', 'Stuart', 'Tarija', '0000', -23.4554707, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Charing Cross', 'Del Mar', 'La Paz', '0000', 51.8417492, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mandrake', 'Larry', 'Cochabamba', '0000', 29.5530941, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clemons', 'Union', 'Potosi', '0000', 59.2426907, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westridge', 'Golden Leaf', 'Pando', '0000', 38.7470186, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('East', 'Fallview', 'chuquisaca', '0000', 48.5129473, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butternut', 'Becker', 'Beni', '0000', 40.7681987, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anderson', 'Oxford', 'Oruro', '0000', 16.0567117, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sauthoff', 'Fairview', 'Tarija', '0000', 29.9905062, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lukken', 'Monica', 'La Paz', '0000', 14.2462858, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lyons', 'Buell', 'Cochabamba', '0000', -23.2218772, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Gulseth', 'Arapahoe', 'Potosi', '0000', 14.7008738, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Ruskin', 'Muir', 'Pando', '0000', 52.7456843, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pearson', 'Becker', 'chuquisaca', '0000', -7.13754, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Quincy', 'Brown', 'Beni', '0000', -6.9126426, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Di Loreto', 'Alpine', 'Oruro', '0000', 40.8276499, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grayhawk', 'Doe Crossing', 'Tarija', '0000', -21.7034017, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Commercial', 'Anderson', 'La Paz', '0000', -10.1771997, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Linden', 'Cordelia', 'Cochabamba', '0000', -7.0453161, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Charing Cross', 'Debs', 'Potosi', '0000', 51.6861013, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mallory', 'Bashford', 'Pando', '0000', 48.418023, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Starling', 'Barby', 'chuquisaca', '0000', -7.13386, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nevada', 'Fairview', 'Beni', '0000', -25.283333, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eastwood', 'David', 'Oruro', '0000', -8.334487, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Michigan', 'Elgar', 'Tarija', '0000', 32.8676912, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Paget', 'Straubel', 'La Paz', '0000', 56.1966377, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakewood', 'Eastlawn', 'Cochabamba', '0000', 6.4315805, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Columbus', 'Arapahoe', 'Potosi', '0000', 40.9089779, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melvin', '6th', 'Pando', '0000', 28.871569, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Park Meadow', 'Becker', 'chuquisaca', '0000', 22.0983236, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bartillon', 'Parkside', 'Beni', '0000', -26.0440358, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pennsylvania', 'Truax', 'Oruro', '0000', 22.775792, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Green', 'Warbler', 'Tarija', '0000', 35.4114708, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Green', 'Heath', 'La Paz', '0000', 51.3531567, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Norway Maple', 'Monica', 'Cochabamba', '0000', 47.5196602, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anthes', 'Northfield', 'Potosi', '0000', 40.8570429, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bayside', 'Northwestern', 'Pando', '0000', 41.118436, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pleasure', 'Scott', 'chuquisaca', '0000', -7.6589782, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Barnett', 'Kings', 'Beni', '0000', -8.1814, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Granby', 'Hansons', 'Oruro', '0000', 48.0482483, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Orin', 'Darwin', 'Tarija', '0000', 38.135005, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('North', 'Clyde Gallagher', 'La Paz', '0000', 48.09967, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Village', 'Randy', 'Cochabamba', '0000', 2.9662346, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Welch', 'Thompson', 'Potosi', '0000', 8.6962086, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Buhler', 'Dovetail', 'Pando', '0000', 42.8043197, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Loeprich', 'Lakewood Gardens', 'chuquisaca', '0000', 60.4624232, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nevada', 'Gateway', 'Beni', '0000', -13.4528458, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waxwing', 'Mayer', 'Oruro', '0000', -20.2973067, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Arkansas', 'Chinook', 'Tarija', '0000', 36.9853085, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grim', 'Welch', 'La Paz', '0000', 49.4875115, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('8th', 'Atwood', 'Cochabamba', '0000', 2.2250009, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Badeau', 'Dwight', 'Potosi', '0000', 2.731033, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Trailsway', 'Washington', 'Pando', '0000', 31.5555726, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sunfield', 'Shelley', 'chuquisaca', '0000', -17.3753589, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waubesa', 'Hooker', 'Beni', '0000', 11.8962488, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maryland', 'Straubel', 'Oruro', '0000', 60.6304039, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Calypso', 'Starling', 'Tarija', '0000', -26.17433, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mayfield', 'Gerald', 'La Paz', '0000', 45.456699, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Cody', 'Havey', 'Cochabamba', '0000', 25.639488, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('East', 'Tony', 'Potosi', '0000', 38.6690462, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('West', 'Farmco', 'Pando', '0000', 52.7634482, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Menomonie', 'Lakewood Gardens', 'chuquisaca', '0000', 50.0281297, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Chinook', 'Linden', 'Beni', '0000', 14.5707297, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Oneill', 'Fisk', 'Oruro', '0000', -8.557437, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golf Course', 'Sycamore', 'Tarija', '0000', -22.6604341, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Katie', 'Butternut', 'La Paz', '0000', 53.3625182, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fulton', 'Spenser', 'Cochabamba', '0000', -7.5450262, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Waubesa', 'Lakeland', 'Potosi', '0000', 31.2266233, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Clove', 'Mallard', 'Pando', '0000', 56.8813564, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Forster', 'Kennedy', 'chuquisaca', '0000', 45.76629, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mesta', 'Hoffman', 'Beni', '0000', -9.7386858, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagan', 'Center', 'Oruro', '0000', 49.4150717, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maywood', 'Veith', 'Tarija', '0000', 48.9648089, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Park Meadow', 'Lukken', 'La Paz', '0000', 13.6343413, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Duke', 'Hintze', 'Cochabamba', '0000', 52.0404797, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fairview', 'Hallows', 'Potosi', '0000', 42.8818379, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Morningstar', 'Westport', 'Pando', '0000', 53.2445421, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Utah', 'Shopko', 'chuquisaca', '0000', 53.2650844, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melby', 'Donald', 'Beni', '0000', 31.231521, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Glendale', 'Independence', 'Oruro', '0000', 61.1251, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lindbergh', 'Buell', 'Tarija', '0000', 14.5001422, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sommers', 'Crest Line', 'La Paz', '0000', 34.983385, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Annamark', 'Homewood', 'Cochabamba', '0000', 23.696757, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Oneill', 'Forest Run', 'Potosi', '0000', 49.1409438, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Memorial', 'Main', 'Pando', '0000', 6.00547, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Graedel', 'Corben', 'chuquisaca', '0000', 48.4353479, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Sullivan', 'Hoffman', 'Beni', '0000', -7.5539241, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Moose', 'Eagle Crest', 'Oruro', '0000', 49.3788944, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Knutson', 'Glendale', 'Tarija', '0000', 36.9473226, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eastwood', 'Brickson Park', 'La Paz', '0000', 54.8133814, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Brickson Park', 'Hansons', 'Cochabamba', '0000', 50.1823264, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Parkside', 'South', 'Potosi', '0000', 49.7291343, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Commercial', 'Manitowish', 'Pando', '0000', 51.4992969, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rowland', 'Spaight', 'chuquisaca', '0000', 22.781631, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mifflin', 'Spohn', 'Beni', '0000', 35.1268513, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fairfield', 'Michigan', 'Oruro', '0000', 36.123561, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Butterfield', 'Brentwood', 'Tarija', '0000', 45.129308, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Dorton', 'Judy', 'La Paz', '0000', 17.563418, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Anthes', 'Valley Edge', 'Cochabamba', '0000', 1.5604242, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nevada', 'Delladonna', 'Potosi', '0000', 34.1230021, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Lake View', 'Pando', '0000', 54.1407588, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('South', 'John Wall', 'chuquisaca', '0000', -46.2763744, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grim', 'Glacier Hill', 'Beni', '0000', -6.1859723, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Westport', 'Heffernan', 'Oruro', '0000', 23.269131, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marquette', 'Linden', 'Tarija', '0000', 32.206857, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Canary', 'Mallory', 'La Paz', '0000', 46.75, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Mitchell', 'Birchwood', 'Cochabamba', '0000', 46.6669865, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Londonderry', 'Maryland', 'Potosi', '0000', 7.5521655, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Donald', 'International', 'Pando', '0000', 23.028956, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Acker', 'Union', 'chuquisaca', '0000', 5.7866228, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Havey', 'Ruskin', 'Beni', '0000', -12.3325, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Golf Course', 'Arkansas', 'Oruro', '0000', 12.269743, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Marquette', 'Hauk', 'Tarija', '0000', 48.8904258, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shelley', 'Eastlawn', 'La Paz', '0000', 7.2077348, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rusk', 'Stoughton', 'Cochabamba', '0000', 56.2884624, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hanson', 'Helena', 'Potosi', '0000', 8.688031, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Tomscot', 'Rieder', 'Pando', '0000', 49.2216972, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Melvin', 'Clyde Gallagher', 'chuquisaca', '0000', 23.0029267, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Alpine', 'Lakeland', 'Beni', '0000', 22.483182, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lakeland', 'Shoshone', 'Oruro', '0000', 40.6236168, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Goodland', 'Truax', 'Tarija', '0000', 27.1291264, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Weeping Birch', 'Dawn', 'La Paz', '0000', -25.416667, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lindbergh', 'Dottie', 'Cochabamba', '0000', -6.6551319, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Raven', 'Porter', 'Potosi', '0000', -7.135868, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Old Shore', 'Cottonwood', 'Pando', '0000', 52.2902011, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Rusk', 'Bunker Hill', 'chuquisaca', '0000', -33.8688197, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Lillian', 'Maple', 'Beni', '0000', 21.6098301, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hermina', 'Bayside', 'Oruro', '0000', 50.6140977, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Luster', 'Huxley', 'Tarija', '0000', 41.6853575, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Bultman', 'Monica', 'La Paz', '0000', 56.4874279, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Maryland', '2nd', 'Cochabamba', '0000', 7.9819727, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Schmedeman', 'Kennedy', 'Potosi', '0000', 43.7563619, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Birchwood', 'Tomscot', 'Pando', '0000', 37.548299, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Texas', 'Artisan', 'chuquisaca', '0000', 52.2608863, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Farmco', 'Toban', 'Beni', '0000', 1.3887283, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Eagle Crest', 'David', 'Oruro', '0000', 45.7123346, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Transport', 'Sauthoff', 'Tarija', '0000', 2.7005604, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('3rd', 'Sherman', 'La Paz', '0000', -8.1844859, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Shopko', 'American', 'Cochabamba', '0000', 14.631218, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Debs', 'South', 'Potosi', '0000', 17.0521348, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Grim', 'Acker', 'Pando', '0000', 14.4547788, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Nobel', 'Vernon', 'chuquisaca', '0000', 11.5762804, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Karstens', 'Knutson', 'Beni', '0000', 59.8664826, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Everett', 'Shasta', 'Oruro', '0000', 48.5986674, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Birchwood', '1st', 'Tarija', '0000', 50.8853797, 9);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('South', 'Lyons', 'La Paz', '0000', -9.0104992, 2);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Manley', 'Miller', 'Cochabamba', '0000', -16.3134305, 3);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Di Loreto', 'Dryden', 'Potosi', '0000', 37.8813153, 4);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Swallow', 'Thierer', 'Pando', '0000', 38.640106, 5);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Fremont', 'Eagan', 'chuquisaca', '0000', 18.9494246, 6);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Hagan', 'Charing Cross', 'Beni', '0000', 26.790544, 7);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Pawling', 'Acker', 'Oruro', '0000', -7.8225811, 8);
insert into Master.address (addr_line1, addr_line2, addr_city, addr_postal_code, addr_spatial_location, addr_prov_id) values ('Thackeray', 'Village', 'Tarija', '0000', 12.8834358, 9);
go

--1.5.-categoria_grupo  5
INSERT INTO Master.category_group(cagro_name, cagro_description, cagro_type,cagro_icon_url) VALUES 
('Individual','Una habitación asignada a una persona. Puede tener una o más camas.','facility', 'https://www.hotelportuense.com/wp-content/uploads/sites/41/2019/05/gallery_Single-room10.jpg'),
('Doble','Una habitación asignada a dos personas. Puede tener una o más camas','facility','https://www.cataloniahotels.com/es/blog/wp-content/uploads/2016/05/habitaci%C3%B3n-doble-catalonia-620x412.jpg'),
('Triple','Una habitación asignada a tres personas. Puede tener dos o más camas','facility','https://www.torrehotelejecutivo.com/images/img-habitacion-triple1.jpg'),
('Quad','Una sala asignada a cuatro personas. Puede tener dos o más camas.','facility','https://www.hotellosalmendros.com/uploads/1/3/9/5/13959225/whatsapp-image-1018-07-02-at-6-50-29-am_3_orig.jpeg'),
('Queen','Una habitación con una cama de matrimonio. Puede ser ocupado por una o más personas','facility','https://hotelsantiagodecompostella.com.ec/wp-content/uploads/2018/08/principal_habitaciones-786x393.jpg'),
('King','Una habitación con una cama king-size. Puede ser ocupado por una o más personas.','facility','https://www.desertpearl.com/uploads/widgets/201410300352235451b5f723633.jpeg?v10'),
('Estudio','Una habitación con una cama de estudio, un sofá que se puede convertir en una cama. También puede tener una cama adicional.','facility','https://www.cataloniahotels.com/es/blog/wp-content/uploads/2016/05/habitaci%C3%B3n-doble-catalonia-620x412.jpg');





--Modulo Hotel 
INSERT INTO Hotel.Hotels(hotel_name,hotel_status,hotel_rating_star,hotel_phonenumber,
hotel_addr_id,hotel_addr_description) VALUES 
('Marriott Santa Cruz de la Sierra Hotel',1,4.7,'3 3424848',1,'4to Anillo Entre Radial 23 Y, Av. Las Ramblas S/N, Santa Cruz de la Sierra'),
('Hotel Continental Park',1,4.2,'71641478',1,'Av. Cañoto 289 Esquina, Santa Cruz de la Sierra'),
('Los Tajibos, a Tribute Portfolio Hotel',1,4.7,'3 3421000',1,'Av. San Martín 455, Santa Cruz de la Sierra'),
('Swissôtel Santa Cruz De La Sierra',1,4.7,'3 3611200',1,'Canal Isuto, Av. La Salle, Edificio Blu Costanera, Los Pachio N 4500, Santa Cruz de la Sierra'),
('Equipetrol Suites Apart Hotel',1,4.2,'77315851',1,'Av. Noel Kempff Mercado 470, Santa Cruz de la Sierra'),
('Hotel Camino Real',1,4.6,'3 3423535',1,'Avenida San Martin &, C. K, Santa Cruz de la Sierra'),
('Yotau All Suites Hotel',1,4.4,'3 3367799',1,'Av. San Martín 7, Santa Cruz de la Sierra'),
('Buganvillas Hotel Suites & Spa',1,4.4,'3 3510400',1,'Avenida Roca y Coronado 901, Santa Cruz de la Sierra');

go

--1.6.-miembros   6
INSERT INTO Master.members (memb_name,memb_description)
  VALUES
   ('Silver','dawdw'),
   ('Gold','dada,'),
   ('VIP','ddadaw'),
   ('Wizard','dadwda')

go

-- 1.7Insertar datos de políticas en la tabla "policy"  7
INSERT INTO Master.policy(poli_name,poli_description)
VALUES
  ('Check-in a partir de las 15:00', 'Los huéspedes pueden registrarse en el hotel a partir de las 15:00 horas.'),
  ('Check-out antes de las 12:00', 'Se requiere que los huéspedes abandonen sus habitaciones antes de las 12:00 del mediodía en el día de salida.'),
  ('No se permiten mascotas', 'El hotel tiene una política de no permitir mascotas en las habitaciones.'),
  ('Prohibido fumar en las habitaciones', 'Fumar está estrictamente prohibido en las habitaciones y en áreas interiores del hotel.'),
  ('Desayuno incluido en la tarifa', 'El desayuno está incluido en la tarifa de la habitación.'),
  ('Wi-Fi gratuito en todas las áreas del hotel', 'El hotel ofrece acceso gratuito a Wi-Fi en todas las áreas públicas y habitaciones.'),
  ('Servicio de habitaciones las 24 horas', 'Los huéspedes pueden solicitar comida y bebida en sus habitaciones en cualquier momento del día o de la noche a través del servicio de habitaciones.'),
  ('Área de estacionamiento gratuito', 'El hotel proporciona estacionamiento gratuito para los huéspedes.'),
  ('Piscina al aire libre disponible', 'Los huéspedes pueden disfrutar de una piscina al aire libre para relajarse y nadar durante su estadía en el hotel.'),
  ('Gimnasio abierto para los huéspedes', 'El hotel cuenta con un gimnasio que está disponible para que los huéspedes puedan mantenerse en forma durante su estadía.'),
  ('Recepción abierta las 24 horas', 'La recepción del hotel está disponible las 24 horas, lo que significa que el personal puede ayudar a los huéspedes en cualquier momento, incluso durante la noche.'),
  ('Caja fuerte disponible en las habitaciones', 'Se proporcionan cajas fuertes en las habitaciones para que los huéspedes puedan guardar sus objetos de valor de manera segura.'),
  ('Servicio de lavandería y planchado', 'Los huéspedes pueden utilizar el servicio de lavandería y planchado del hotel para mantener su ropa limpia y en buen estado.'),
  ('Política de cancelación de 24 horas', 'Los huéspedes deben cancelar sus reservas al menos con 24 horas de anticipación para evitar cargos por cancelación.'),
  ('Tarjetas de crédito aceptadas como forma de pago', 'El hotel acepta tarjetas de crédito como forma de pago, lo que brinda comodidad a los huéspedes al realizar transacciones.'),
  ('No se permite el acceso a personas no registradas en las habitaciones', 'Por razones de seguridad, solo las personas registradas en una habitación tienen permiso para ingresar a ella.'),
  ('Restaurante en el hotel abierto para el desayuno, almuerzo y cena', 'El hotel cuenta con un restaurante que sirve comidas durante todo el día, lo que brinda opciones de comida conveniente para los huéspedes.'),
  ('Servicio de transporte al aeropuerto disponible bajo petición', 'Los huéspedes pueden solicitar un servicio de transporte desde y hacia el aeropuerto con previo aviso al hotel.'),
  ('Habitaciones con aire acondicionado', 'Todas las habitaciones del hotel están equipadas con aire acondicionado para garantizar una temperatura agradable en todas las estaciones del año.'),
  ('Servicio de conserjería para ayudar a los huéspedes', 'El personal de conserjería del hotel está disponible para ayudar a los huéspedes con reservas y recomendaciones locales.'),
  ('Servicio de alquiler de coches en el lugar', 'Los huéspedes pueden alquilar un coche directamente en el hotel para su conveniencia.'),
  ('Habitaciones familiares disponibles', 'El hotel ofrece habitaciones diseñadas especialmente para familias, con espacio adicional y comodidades.'),
  ('Política de respeto al medio ambiente y sostenibilidad', 'El hotel se compromete a tomar medidas para reducir su impacto ambiental y promover prácticas sostenibles.'),
  ('Habitaciones adaptadas para personas con discapacidad', 'El hotel cuenta con habitaciones diseñadas para la comodidad y accesibilidad de las personas con discapacidad.'),
  ('Servicio de despertador disponible', 'Los huéspedes pueden solicitar un servicio de despertador para asegurarse de no perder compromisos importantes durante su estadía.');
   go


--1.8 politicas_categoria_grupo   8
INSERT INTO Master.policy_category_group (poca_poli_id, poca_cagro_id)
VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (4, 1),
  (5, 1),
  (6, 1),
  (7, 1),
  (8, 1),
  (9, 1),
  (10, 1),
  (11, 2),
  (12, 2),
  (13, 2),
  (14, 2),
  (15, 2),
  (16, 2),
  (17, 2),
  (18, 2),
  (19, 2),
  (20, 2),
  (21, 3),
  (22, 3),
  (23, 3),
  (24, 3),
  (25, 3);
  go


  --1.9  tareas de servicio  9
INSERT INTO Master.service_task (seta_name)
VALUES
  ('Limpieza de habitaciones'),
  ('Cambio de sábanas'),
  ('Reposición de toallas'),
  ('Servicio de despertador'),
  ('Mantenimiento de instalaciones'),
  ('Servicio de habitaciones'),
  ('Atención al cliente'),
  ('Recepción de huéspedes'),
  ('Gestión de reservas'),
  ('Servicio de conserjería'),
  ('Servicio de lavandería'),
  ('Servicio de restaurante'),
  ('Servicio de bar'),
  ('Servicio de piscina'),
  ('Servicio de gimnasio'),
  ('Servicio de spa'),
  ('Organización de eventos'),
  ('Servicio de transporte'),
  ('Asistencia turística'),
  ('Seguridad del hotel');
  go

-- 1.10 price_items    10
INSERT INTO Master.price_items (prit_name, prit_price, prit_description, prit_type, prit_icon_url, prit_modified_date)
VALUES
  ('Snack 1', 2.99, 'Snack description 1', 'SNACK', 'https://example.com/snack1.png', GETDATE()),
  ('Facility 1', 5.99, 'Facility description 1', 'FACILITY', 'https://example.com/facility1.png', GETDATE()),
  ('Softdrink 1', 1.99, 'Softdrink description 1', 'SOFTDRINK', 'https://example.com/softdrink1.png', GETDATE()),
  ('Food 1', 7.99, 'Food description 1', 'FOOD', 'https://example.com/food1.png', GETDATE()),
  ('Service 1', 9.99, 'Service description 1', 'SERVICE', 'https://example.com/service1.png', GETDATE()),
  ('Snack 2', 3.99, 'Snack description 2', 'SNACK', 'https://example.com/snack2.png', GETDATE()),
  ('Facility 2', 6.99, 'Facility description 2', 'FACILITY', 'https://example.com/facility2.png', GETDATE()),
  ('Softdrink 2', 2.49, 'Softdrink description 2', 'SOFTDRINK', 'https://example.com/softdrink2.png', GETDATE()),
  ('Food 2', 8.99, 'Food description 2', 'FOOD', 'https://example.com/food2.png', GETDATE()),
  ('Service 2', 10.99, 'Service description 2', 'SERVICE', 'https://example.com/service2.png', GETDATE()),
  ('Snack 3', 4.49, 'Snack description 3', 'SNACK', 'https://example.com/snack3.png', GETDATE()),
  ('Facility 3', 7.49, 'Facility description 3', 'FACILITY', 'https://example.com/facility3.png', GETDATE()),
  ('Softdrink 3', 2.99, 'Softdrink description 3', 'SOFTDRINK', 'https://example.com/softdrink3.png', GETDATE()),
  ('Food 3', 9.49, 'Food description 3', 'FOOD', 'https://example.com/food3.png', GETDATE()),
  ('Service 3', 11.49, 'Service description 3', 'SERVICE', 'https://example.com/service3.png', GETDATE()),
  ('Snack 4', 4.99, 'Snack description 4', 'SNACK', 'https://example.com/snack4.png', GETDATE()),
  ('Facility 4', 8.99, 'Facility description 4', 'FACILITY', 'https://example.com/facility4.png', GETDATE()),
  ('Softdrink 4', 3.49, 'Softdrink description 4', 'SOFTDRINK', 'https://example.com/softdrink4.png', GETDATE()),
  ('Food 4', 10.99, 'Food description 4', 'FOOD', 'https://example.com/food4.png', GETDATE()),
  ('Service 4', 12.99, 'Service description 4', 'SERVICE', 'https://example.com/service4.png', GETDATE());
go


--------------------------------Modulo Users----------------------------------------------------------
---2.1 Usuarios    11
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ximenes Dingivan', 'T', 'Vidoo', 'xdingivan0@skype.com', '680 965 1942');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brant Wycliffe', 'I', 'Layo', 'bwycliffe1@wisc.edu', '421 338 1919');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Theobald Curryer', 'T', 'Eidel', 'tcurryer2@php.net', '554 492 1224');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bobbi Breadon', 'T', 'Voonyx', 'bbreadon3@mail.ru', '909 677 1729');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bennie Kamena', 'T', 'Quamba', 'bkamena4@stanford.edu', '256 872 6767');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kalindi Seakings', 'T', 'Eimbee', 'kseakings5@weibo.com', '989 514 4234');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Celene Jiran', 'T', 'Zooxo', 'cjiran6@aboutads.info', '653 475 6008');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gustavus Garken', 'I', 'Dabjam', 'ggarken7@prnewswire.com', '389 900 9383');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gilligan Greenslade', 'C', 'Shuffletag', 'ggreenslade8@springer.com', '757 914 8935');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hadria Saggs', 'I', 'Gigazoom', 'hsaggs9@usnews.com', '403 297 5547');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cosette Walch', 'C', 'Edgeblab', 'cwalcha@goo.gl', '281 286 2350');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jase Kynson', 'I', 'Mybuzz', 'jkynsonb@printfriendly.com', '851 615 4672');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Verney Searby', 'C', 'Einti', 'vsearbyc@naver.com', '450 249 4571');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Justino Fehners', 'T', 'Quamba', 'jfehnersd@boston.com', '208 402 4245');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ava De Simone', 'I', 'Dabjam', 'adee@ifeng.com', '211 454 4268');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Waverly Rutherfoord', 'I', 'Jaxnation', 'wrutherfoordf@yale.edu', '218 927 5728');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Concettina Dorling', 'C', 'Avaveo', 'cdorlingg@hatena.ne.jp', '237 144 1270');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Heinrik Skrines', 'C', 'Twitternation', 'hskrinesh@sina.com.cn', '417 806 8339');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hamnet Zanini', 'T', 'Minyx', 'hzaninii@t.co', '740 956 1249');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hetty Gyde', 'C', 'Flipstorm', 'hgydej@tuttocitta.it', '271 113 7960');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dwayne Chugg', 'I', 'Aivee', 'dchuggk@walmart.com', '255 505 5242');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dorothea D''Ruel', 'T', 'Riffpedia', 'ddruell@uol.com.br', '295 945 4934');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emilee Pagitt', 'I', 'Linkbuzz', 'epagittm@irs.gov', '118 626 4792');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Derrik Hutcheon', 'I', 'Tekfly', 'dhutcheonn@irs.gov', '501 926 4350');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vonny Piens', 'T', 'Photobug', 'vpienso@altervista.org', '819 823 9295');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Evelyn Mangeon', 'I', 'Skilith', 'emangeonp@bloglines.com', '376 367 9984');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Selestina Scragg', 'T', 'Livefish', 'sscraggq@omniture.com', '133 186 8255');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Allyn Jobin', 'I', 'Kazu', 'ajobinr@paginegialle.it', '214 518 4862');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Virge Lawful', 'C', 'Brainverse', 'vlawfuls@senate.gov', '448 719 2623');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Geralda Carnegie', 'C', 'Realcube', 'gcarnegiet@un.org', '598 600 7487');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Matt Nairy', 'I', 'Shuffletag', 'mnairyu@nih.gov', '268 398 6184');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bastien Stroulger', 'C', 'Fanoodle', 'bstroulgerv@weibo.com', '945 329 3605');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dot Thorneywork', 'I', 'Eazzy', 'dthorneyworkw@google.co.uk', '333 459 1996');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arther Oliva', 'C', 'Tazzy', 'aolivax@bing.com', '594 768 7723');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nevile Frostdicke', 'T', 'Miboo', 'nfrostdickey@pcworld.com', '512 865 6966');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cari Judkin', 'C', 'Wikido', 'cjudkinz@umn.edu', '651 366 7119');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sibilla Wakeford', 'I', 'Skiptube', 'swakeford10@wikia.com', '393 754 1262');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mohandas Casolla', 'T', 'Skiptube', 'mcasolla11@phoca.cz', '166 175 2566');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Zak Duester', 'I', 'Twitterworks', 'zduester12@guardian.co.uk', '379 244 0916');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marge Fielding', 'I', 'Zooxo', 'mfielding13@icio.us', '821 717 3443');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clarey Le Marchand', 'I', 'Centizu', 'cle14@wikipedia.org', '789 749 8208');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ardelis Drexel', 'T', 'Devpoint', 'adrexel15@newsvine.com', '567 667 0306');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Balduin Maryet', 'C', 'Trudoo', 'bmaryet16@bravesites.com', '874 748 6275');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ximenes O''Carroll', 'T', 'Gabvine', 'xocarroll17@com.com', '229 246 6933');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Livy Bonett', 'C', 'Yodel', 'lbonett18@chronoengine.com', '669 661 5876');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kylynn Jenckes', 'C', 'Linktype', 'kjenckes19@state.gov', '666 924 2706');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raimundo Kirkby', 'T', 'Jabbersphere', 'rkirkby1a@elpais.com', '458 558 2674');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rosemonde Frossell', 'T', 'Aibox', 'rfrossell1b@disqus.com', '700 908 6445');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Danie Benger', 'I', 'Thoughtworks', 'dbenger1c@bbc.co.uk', '911 573 1659');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Myrle McNulty', 'C', 'Centizu', 'mmcnulty1d@bigcartel.com', '708 228 1346');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mike Poznanski', 'I', 'Gabtype', 'mpoznanski1e@sphinn.com', '722 876 6054');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Terri Stebbing', 'T', 'Thoughtstorm', 'tstebbing1f@wikipedia.org', '771 989 9031');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nelle Fairleigh', 'I', 'InnoZ', 'nfairleigh1g@networksolutions.com', '915 956 0616');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Glenine Proppers', 'T', 'Quimba', 'gproppers1h@mysql.com', '582 324 2076');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Charleen Ilbert', 'C', 'DabZ', 'cilbert1i@sohu.com', '183 971 3782');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Francklin Craigs', 'I', 'Skilith', 'fcraigs1j@webmd.com', '342 399 9757');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Burgess Girault', 'I', 'Tagcat', 'bgirault1k@ebay.co.uk', '408 238 7045');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hort Yankishin', 'T', 'Realcube', 'hyankishin1l@tripod.com', '209 441 3335');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Myrvyn Baelde', 'C', 'Flipopia', 'mbaelde1m@webs.com', '365 152 1707');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Deina Jandera', 'I', 'Quatz', 'djandera1n@wordpress.com', '695 151 2381');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pietrek Wabersinke', 'C', 'Trunyx', 'pwabersinke1o@mapquest.com', '886 639 2495');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Janith Gusticke', 'C', 'Yoveo', 'jgusticke1p@hubpages.com', '607 362 4930');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raine Renon', 'I', 'Realbuzz', 'rrenon1q@xrea.com', '904 880 0938');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Christabella Robelin', 'I', 'Zoomcast', 'crobelin1r@bloglovin.com', '914 384 9366');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Callean Olivetti', 'T', 'Katz', 'colivetti1s@vinaora.com', '571 131 5758');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Billy Richardt', 'I', 'Brainlounge', 'brichardt1t@soundcloud.com', '124 774 8452');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mercie Ciric', 'C', 'Voonix', 'mciric1u@is.gd', '626 185 0602');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Amil Sydenham', 'C', 'Gabtype', 'asydenham1v@upenn.edu', '504 624 6119');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Thomasa Stonebridge', 'C', 'Youbridge', 'tstonebridge1w@baidu.com', '566 346 0680');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Myrtice Rive', 'T', 'Flashspan', 'mrive1x@bluehost.com', '259 997 1330');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Obediah Rome', 'I', 'Voomm', 'orome1y@businessinsider.com', '492 385 0990');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Calli Munnings', 'T', 'Roodel', 'cmunnings1z@washingtonpost.com', '602 686 3190');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Andonis Weakley', 'T', 'Livepath', 'aweakley20@wikispaces.com', '133 804 6735');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Byrle Leak', 'T', 'Zoomzone', 'bleak21@businesswire.com', '735 958 8355');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gennifer Raggatt', 'T', 'Photospace', 'graggatt22@prweb.com', '638 547 6720');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eda Vanyushin', 'T', 'Youtags', 'evanyushin23@jugem.jp', '923 524 0901');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sally Bexon', 'T', 'Wordify', 'sbexon24@github.com', '968 803 9023');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Melitta Sesser', 'T', 'Demimbu', 'msesser25@hc360.com', '980 632 3171');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jdavie Simes', 'C', 'Yodoo', 'jsimes26@dailymotion.com', '801 619 9098');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berk Neeson', 'T', 'Jaxspan', 'bneeson27@pbs.org', '293 438 8418');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sutton Fane', 'I', 'Feedspan', 'sfane28@sitemeter.com', '583 409 8222');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lianne Trenbey', 'C', 'Realpoint', 'ltrenbey29@dell.com', '310 982 9804');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hi Iacovelli', 'C', 'Plajo', 'hiacovelli2a@timesonline.co.uk', '868 297 5641');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alasteir Broun', 'C', 'Riffpedia', 'abroun2b@ning.com', '909 816 5119');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wendye Wenden', 'I', 'Aibox', 'wwenden2c@timesonline.co.uk', '340 918 5134');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hilly Camfield', 'T', 'Blogpad', 'hcamfield2d@ezinearticles.com', '425 441 5575');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wainwright Corradini', 'I', 'Skivee', 'wcorradini2e@drupal.org', '339 818 9963');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marcile Chesser', 'C', 'Yabox', 'mchesser2f@epa.gov', '862 837 8734');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ario Souter', 'T', 'Edgetag', 'asouter2g@huffingtonpost.com', '301 959 8029');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gunter Bootes', 'C', 'Flipbug', 'gbootes2h@theguardian.com', '850 965 6459');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Regan Craw', 'T', 'Gabvine', 'rcraw2i@princeton.edu', '788 474 8368');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Corny Armytage', 'C', 'Jazzy', 'carmytage2j@accuweather.com', '534 721 2628');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Danyette Asp', 'T', 'Babbleset', 'dasp2k@elpais.com', '669 949 8881');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tedra Maiden', 'I', 'Bubblebox', 'tmaiden2l@meetup.com', '352 514 0677');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dimitry Shuter', 'I', 'Janyx', 'dshuter2m@example.com', '456 659 2038');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nevil Muzzlewhite', 'I', 'Gabtune', 'nmuzzlewhite2n@wordpress.org', '610 390 7038');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Camile Escott', 'C', 'Quinu', 'cescott2o@ucoz.ru', '839 580 8616');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marcela MacCorley', 'C', 'Quire', 'mmaccorley2p@mtv.com', '231 917 4391');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Meggi Gaudin', 'I', 'Buzzbean', 'mgaudin2q@unc.edu', '829 718 0124');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Phillis Rozea', 'I', 'Youopia', 'prozea2r@independent.co.uk', '472 994 0678');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gannie Dennant', 'T', 'Demizz', 'gdennant2s@ucoz.com', '606 687 5761');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Violante Nix', 'I', 'Edgeclub', 'vnix2t@g.co', '539 869 5530');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Byrom Coiley', 'I', 'Meevee', 'bcoiley2u@topsy.com', '822 535 0292');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Demetra Hanretty', 'C', 'Quire', 'dhanretty2v@pagesperso-orange.fr', '588 831 3454');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lauren Greydon', 'T', 'Youtags', 'lgreydon2w@guardian.co.uk', '781 799 1508');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yulma Wallington', 'C', 'Shufflebeat', 'ywallington2x@youku.com', '519 560 5445');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Archibold Savery', 'I', 'Yakidoo', 'asavery2y@tinypic.com', '963 322 3695');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Muire Butrimovich', 'T', 'Realbridge', 'mbutrimovich2z@newsvine.com', '916 760 2006');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Teodoro Tuite', 'T', 'Demivee', 'ttuite30@github.com', '424 405 1074');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Abbi Downer', 'C', 'Vipe', 'adowner31@issuu.com', '387 756 0640');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Meredith Tellesson', 'C', 'Wordware', 'mtellesson32@imgur.com', '636 707 3744');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fern Borell', 'I', 'Vimbo', 'fborell33@privacy.gov.au', '889 261 1682');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Merell Hornig', 'T', 'Abata', 'mhornig34@webmd.com', '108 979 9092');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Briney Banaszkiewicz', 'I', 'Centizu', 'bbanaszkiewicz35@statcounter.com', '411 110 7262');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ronny Crufts', 'I', 'Aimbo', 'rcrufts36@google.it', '180 107 0389');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adolphus Priestman', 'C', 'Jaxbean', 'apriestman37@ebay.com', '945 694 3068');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kelvin Rowsel', 'T', 'Zoombox', 'krowsel38@cocolog-nifty.com', '202 983 4811');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maybelle Pirazzi', 'T', 'Oyonder', 'mpirazzi39@census.gov', '739 801 8412');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Benjie Southan', 'C', 'Edgetag', 'bsouthan3a@wunderground.com', '860 680 1960');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Coreen Budleigh', 'T', 'Gigaclub', 'cbudleigh3b@fotki.com', '889 450 8666');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Miltie Whittlesee', 'C', 'Brainbox', 'mwhittlesee3c@exblog.jp', '929 100 9896');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Aeriel Cleve', 'C', 'Centimia', 'acleve3d@icq.com', '299 368 2702');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adrianne Philipps', 'C', 'Dabshots', 'aphilipps3e@who.int', '672 762 0944');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Guntar Chilles', 'C', 'Brainlounge', 'gchilles3f@prnewswire.com', '894 630 7177');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Oswell Salla', 'I', 'Rhynyx', 'osalla3g@timesonline.co.uk', '994 347 2146');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wynn Feldhorn', 'I', 'Plajo', 'wfeldhorn3h@hostgator.com', '606 943 0463');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nicolle Dyble', 'C', 'Einti', 'ndyble3i@home.pl', '611 182 4575');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tami McCarly', 'C', 'Shufflebeat', 'tmccarly3j@chron.com', '666 169 3615');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bellanca Cowlishaw', 'C', 'Meetz', 'bcowlishaw3k@xinhuanet.com', '509 326 1667');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Micheal Willatts', 'T', 'Shuffletag', 'mwillatts3l@newyorker.com', '449 820 1807');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Edyth Clemmow', 'C', 'Livefish', 'eclemmow3m@state.gov', '291 611 1264');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Deeyn Harler', 'C', 'Dabjam', 'dharler3n@chronoengine.com', '147 730 9012');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Doralin Duchenne', 'T', 'Roodel', 'dduchenne3o@auda.org.au', '810 490 9692');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kaycee Bodega', 'I', 'Skyble', 'kbodega3p@eventbrite.com', '742 218 8973');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sarene Gleave', 'T', 'Podcat', 'sgleave3q@imageshack.us', '245 411 3531');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kennedy Beatens', 'I', 'Gabspot', 'kbeatens3r@netvibes.com', '212 376 2443');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kala Breit', 'C', 'BlogXS', 'kbreit3s@flavors.me', '988 692 2865');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hank Balaison', 'C', 'Feedfire', 'hbalaison3t@ftc.gov', '508 675 1836');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ethel Jirik', 'T', 'Skipfire', 'ejirik3u@seesaa.net', '650 930 1821');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Garrott Jewel', 'I', 'Eamia', 'gjewel3v@chron.com', '752 823 3853');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Karney Joffe', 'I', 'Blognation', 'kjoffe3w@chicagotribune.com', '389 709 3035');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jimmie Maunsell', 'T', 'Trunyx', 'jmaunsell3x@whitehouse.gov', '601 292 0942');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Noll Van Brug', 'T', 'Livepath', 'nvan3y@goo.gl', '247 358 5623');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Al Claricoates', 'C', 'Tagcat', 'aclaricoates3z@japanpost.jp', '801 158 6351');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bald Foulks', 'T', 'Twinder', 'bfoulks40@hugedomains.com', '359 658 6604');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cate McNeish', 'I', 'Kazu', 'cmcneish41@hao123.com', '620 534 1238');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maryanne Davison', 'T', 'Zoomcast', 'mdavison42@domainmarket.com', '734 834 8020');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mohandis Conner', 'C', 'Shufflester', 'mconner43@topsy.com', '577 980 6508');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Darla Domaschke', 'T', 'Linkbridge', 'ddomaschke44@ihg.com', '381 672 0950');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Felice Devenish', 'C', 'Quaxo', 'fdevenish45@jugem.jp', '310 504 6531');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Larina Hughland', 'C', 'Browsedrive', 'lhughland46@tinyurl.com', '967 330 8107');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Robbi Soigoux', 'C', 'Wikizz', 'rsoigoux47@un.org', '522 264 9402');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Erny Branca', 'T', 'Youspan', 'ebranca48@guardian.co.uk', '249 752 5958');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rea Loughton', 'I', 'Yacero', 'rloughton49@cnn.com', '826 645 2749');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sapphire Binnes', 'T', 'Eimbee', 'sbinnes4a@example.com', '503 859 5024');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cairistiona Sybbe', 'C', 'Yabox', 'csybbe4b@trellian.com', '824 242 6151');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lanie Sacaze', 'I', 'Zooveo', 'lsacaze4c@skype.com', '555 531 6634');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kyle Chastey', 'T', 'Skyble', 'kchastey4d@imageshack.us', '130 714 9388');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Miller Betancourt', 'I', 'Jabbertype', 'mbetancourt4e@utexas.edu', '621 684 8696');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ralf Skirvane', 'C', 'Jamia', 'rskirvane4f@imageshack.us', '249 438 3349');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jany Portail', 'T', 'Layo', 'jportail4g@nymag.com', '915 225 4925');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cozmo Pennycord', 'I', 'Skibox', 'cpennycord4h@so-net.ne.jp', '919 822 4200');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Huberto Loftin', 'C', 'Brainsphere', 'hloftin4i@usgs.gov', '379 902 0888');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winnie Rehme', 'T', 'Meedoo', 'wrehme4j@jiathis.com', '629 364 0511');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Noland Mordaunt', 'C', 'Jabberbean', 'nmordaunt4k@bing.com', '237 531 1139');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cathrin Newiss', 'C', 'Youspan', 'cnewiss4l@tiny.cc', '201 266 1728');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carole Filtness', 'C', 'Photobean', 'cfiltness4m@studiopress.com', '668 406 5448');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Glori Moyes', 'I', 'Browsedrive', 'gmoyes4n@scribd.com', '898 478 3853');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marika Farrans', 'C', 'Gabspot', 'mfarrans4o@nydailynews.com', '379 552 8797');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hulda Waite', 'I', 'Plajo', 'hwaite4p@webs.com', '229 232 3082');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roberto Charlton', 'T', 'Jatri', 'rcharlton4q@un.org', '280 736 3766');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Margo Queree', 'T', 'Shuffletag', 'mqueree4r@tripadvisor.com', '940 546 4994');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wilmer McColl', 'C', 'Skimia', 'wmccoll4s@cmu.edu', '969 148 3245');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mark Pavolillo', 'T', 'Shufflebeat', 'mpavolillo4t@baidu.com', '102 476 5174');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arlyne Firsby', 'C', 'Topicblab', 'afirsby4u@java.com', '512 627 0133');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Teddy Duckels', 'T', 'Kaymbo', 'tduckels4v@dropbox.com', '341 347 9661');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Johnathan Godlip', 'T', 'Avaveo', 'jgodlip4w@va.gov', '364 660 4401');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cyrus Hryncewicz', 'C', 'Babbleset', 'chryncewicz4x@dropbox.com', '248 829 5101');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mareah Honeyghan', 'C', 'Wordware', 'mhoneyghan4y@simplemachines.org', '375 932 8790');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ralf Veel', 'T', 'Jaxbean', 'rveel4z@biblegateway.com', '607 200 2753');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tandie Wellwood', 'T', 'BlogXS', 'twellwood50@multiply.com', '883 640 8459');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Breena de Wilde', 'I', 'Wikivu', 'bde51@hhs.gov', '697 625 4949');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wilhelmina Ulyatt', 'I', 'Oba', 'wulyatt52@acquirethisname.com', '662 135 1339');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fanchon Mably', 'C', 'Wordware', 'fmably53@cmu.edu', '958 786 3748');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maris Thistleton', 'T', 'Blognation', 'mthistleton54@ameblo.jp', '833 126 9559');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lindsay Beartup', 'I', 'Skidoo', 'lbeartup55@wikispaces.com', '233 891 3427');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gael Alderton', 'I', 'Browsedrive', 'galderton56@ifeng.com', '804 802 5275');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Colleen Larn', 'C', 'Trilia', 'clarn57@a8.net', '972 684 8579');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hinze Simonetti', 'I', 'Skibox', 'hsimonetti58@amazon.co.uk', '507 904 9381');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Washington Allerton', 'C', 'Tagfeed', 'wallerton59@chronoengine.com', '348 823 6314');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Loella Hun', 'T', 'Eimbee', 'lhun5a@webs.com', '854 869 5689');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cosette Posvner', 'C', 'Kwinu', 'cposvner5b@fc2.com', '704 536 6427');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hardy Spuffard', 'T', 'Skippad', 'hspuffard5c@technorati.com', '697 273 5994');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hodge Espina', 'T', 'Centimia', 'hespina5d@i2i.jp', '209 623 7263');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Spike Grube', 'T', 'Ooba', 'sgrube5e@examiner.com', '206 896 0630');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nickey Gummory', 'I', 'Youspan', 'ngummory5f@elegantthemes.com', '692 672 0706');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cahra Bredgeland', 'C', 'Quimba', 'cbredgeland5g@blogger.com', '341 461 8427');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Linc Omond', 'C', 'Jetpulse', 'lomond5h@tripod.com', '764 988 4640');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Klarrisa Smalley', 'I', 'Quimm', 'ksmalley5i@sitemeter.com', '506 707 2266');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sheilah Gibbings', 'T', 'Meeveo', 'sgibbings5j@jugem.jp', '621 837 4278');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Celestyna Phidgin', 'I', 'Kimia', 'cphidgin5k@whitehouse.gov', '111 491 0047');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Janean Boothby', 'T', 'Skyba', 'jboothby5l@sphinn.com', '460 564 6267');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gael Corcut', 'T', 'Skyba', 'gcorcut5m@shareasale.com', '894 849 5535');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carlene Iannuzzelli', 'T', 'Feedfire', 'ciannuzzelli5n@diigo.com', '227 186 0587');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hillery Camsey', 'C', 'Jabbercube', 'hcamsey5o@wsj.com', '842 117 5612');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tim Bourthouloume', 'T', 'Rhyloo', 'tbourthouloume5p@wikia.com', '145 772 9828');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Garv Ohms', 'C', 'Teklist', 'gohms5q@goo.ne.jp', '657 260 0786');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Niven Gaiger', 'I', 'Skyba', 'ngaiger5r@rakuten.co.jp', '567 359 2817');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mary Andreia', 'I', 'Jaloo', 'mandreia5s@last.fm', '317 831 6271');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gale Adrien', 'C', 'Bubblemix', 'gadrien5t@squidoo.com', '656 700 0691');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Crysta Catlow', 'I', 'Blogtag', 'ccatlow5u@delicious.com', '333 862 8417');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ashley Blacksland', 'T', 'Einti', 'ablacksland5v@1688.com', '338 199 2354');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Abran Mattia', 'C', 'Skyba', 'amattia5w@princeton.edu', '712 633 2533');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Milena Desforges', 'I', 'Pixonyx', 'mdesforges5x@bandcamp.com', '171 536 8032');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alfy Nugent', 'T', 'Trunyx', 'anugent5y@surveymonkey.com', '546 233 2565');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ezekiel Sorrill', 'I', 'Livetube', 'esorrill5z@java.com', '597 567 9676');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Xavier Bollin', 'T', 'Flipbug', 'xbollin60@indiegogo.com', '100 526 4350');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Britni Eubank', 'I', 'Skipstorm', 'beubank61@seattletimes.com', '263 561 3109');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Christoffer Hamill', 'C', 'Livetube', 'chamill62@samsung.com', '526 155 8622');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wakefield Hayball', 'C', 'Yakidoo', 'whayball63@artisteer.com', '352 975 3508');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Darla Jillis', 'C', 'Skipfire', 'djillis64@fema.gov', '199 143 1771');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barbie Poor', 'T', 'Mycat', 'bpoor65@infoseek.co.jp', '845 241 2164');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Salomi Dansie', 'T', 'Brightbean', 'sdansie66@theatlantic.com', '279 934 4919');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tessie Thibodeaux', 'T', 'Buzzbean', 'tthibodeaux67@so-net.ne.jp', '514 497 7096');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gradey Jellyman', 'C', 'Twimm', 'gjellyman68@nih.gov', '752 203 9306');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Urson Polleye', 'T', 'Mycat', 'upolleye69@cloudflare.com', '562 828 3412');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adeline Regelous', 'I', 'Zoonder', 'aregelous6a@infoseek.co.jp', '492 357 3155');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Paten Pepperrall', 'I', 'Devbug', 'ppepperrall6b@weibo.com', '711 320 8598');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ad Pinchen', 'C', 'Katz', 'apinchen6c@amazon.de', '324 309 2483');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rubia Fountaine', 'T', 'Roomm', 'rfountaine6d@unblog.fr', '378 872 3980');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lorens Addams', 'I', 'Mita', 'laddams6e@printfriendly.com', '201 148 6964');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gideon Machent', 'T', 'Yakijo', 'gmachent6f@squidoo.com', '809 489 6734');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Amelia Addeycott', 'I', 'Wordware', 'aaddeycott6g@wikia.com', '359 243 0701');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winthrop O''Roan', 'T', 'Skiptube', 'woroan6h@digg.com', '244 369 2529');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jarrod Sannes', 'C', 'Zoomzone', 'jsannes6i@craigslist.org', '207 164 3733');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Case Biesterfeld', 'C', 'Gabvine', 'cbiesterfeld6j@chicagotribune.com', '217 305 8131');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Julee Vial', 'C', 'Oyonder', 'jvial6k@jimdo.com', '596 205 0684');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Betsy Rogister', 'C', 'Einti', 'brogister6l@wiley.com', '269 195 4014');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Stefano Plues', 'C', 'Eazzy', 'splues6m@storify.com', '322 996 3738');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Glad Stairs', 'T', 'Buzzbean', 'gstairs6n@washington.edu', '616 865 1292');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Esmeralda Meaton', 'T', 'Mudo', 'emeaton6o@feedburner.com', '777 254 5600');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Caroljean Ambrogio', 'C', 'Photolist', 'cambrogio6p@psu.edu', '611 152 1682');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tessy Reedman', 'I', 'Fiveclub', 'treedman6q@mysql.com', '941 836 7109');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Desirae Goodbairn', 'C', 'Ainyx', 'dgoodbairn6r@sfgate.com', '373 456 8852');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dani Asser', 'I', 'Devpoint', 'dasser6s@amazon.de', '638 288 7833');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rancell Dudden', 'C', 'Oyondu', 'rdudden6t@squidoo.com', '745 444 3651');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mick Auletta', 'T', 'Fivechat', 'mauletta6u@jalbum.net', '926 433 4493');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Teddie Haxell', 'I', 'Shufflester', 'thaxell6v@eventbrite.com', '422 291 9285');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Agathe Lindenbluth', 'C', 'Edgewire', 'alindenbluth6w@weather.com', '649 223 6607');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emery Ellingham', 'I', 'Talane', 'eellingham6x@icio.us', '526 102 2712');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Quintin Fosdike', 'T', 'Demizz', 'qfosdike6y@aol.com', '342 442 6143');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bobbie Fasey', 'T', 'Buzzster', 'bfasey6z@bloglines.com', '680 730 6417');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barnard Labadini', 'I', 'Podcat', 'blabadini70@virginia.edu', '837 439 1709');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rozella Foulsham', 'T', 'Fanoodle', 'rfoulsham71@fc2.com', '529 271 3911');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Oberon Kearsley', 'C', 'Topicblab', 'okearsley72@soup.io', '779 761 7724');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Egan Olliar', 'I', 'Snaptags', 'eolliar73@uiuc.edu', '461 107 5322');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Giff Boggas', 'T', 'Twitterwire', 'gboggas74@google.com', '760 114 3184');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ogden Aurelius', 'C', 'Edgewire', 'oaurelius75@aboutads.info', '602 845 2489');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Matelda Barbrick', 'T', 'Blogspan', 'mbarbrick76@stanford.edu', '459 151 1400');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Francisco Forber', 'I', 'Meembee', 'fforber77@house.gov', '191 819 6350');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Van Beeswing', 'T', 'Browseblab', 'vbeeswing78@craigslist.org', '303 397 4487');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jackie Klarzynski', 'C', 'Edgepulse', 'jklarzynski79@eepurl.com', '956 680 3325');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Frank Brankley', 'I', 'Photolist', 'fbrankley7a@ucla.edu', '592 828 6624');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Shel Sowle', 'C', 'Trupe', 'ssowle7b@artisteer.com', '529 855 4752');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gratiana Rable', 'C', 'Skynoodle', 'grable7c@zimbio.com', '275 135 1460');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Miranda Fanti', 'T', 'Dablist', 'mfanti7d@technorati.com', '645 642 9956');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eugenie Eliassen', 'I', 'InnoZ', 'eeliassen7e@jalbum.net', '802 421 5745');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Frasquito Talmadge', 'C', 'Ainyx', 'ftalmadge7f@dropbox.com', '419 825 7215');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brook Conquer', 'T', 'Kwideo', 'bconquer7g@ihg.com', '326 891 1982');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hedda Vedeniktov', 'I', 'Skibox', 'hvedeniktov7h@walmart.com', '409 150 3472');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barron Jachimczak', 'C', 'Linklinks', 'bjachimczak7i@weebly.com', '959 793 7367');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Erinna Wardley', 'C', 'Centizu', 'ewardley7j@myspace.com', '751 711 3763');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mateo Penhall', 'C', 'Oyoloo', 'mpenhall7k@plala.or.jp', '303 287 0055');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Whit Marchand', 'C', 'Centizu', 'wmarchand7l@whitehouse.gov', '888 247 1628');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sammy Cersey', 'C', 'Vimbo', 'scersey7m@ucoz.com', '375 850 6248');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lindsey Armsden', 'C', 'Quinu', 'larmsden7n@diigo.com', '722 854 8772');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gayel Smorfit', 'C', 'Kwilith', 'gsmorfit7o@feedburner.com', '229 806 8079');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Edsel Selwood', 'I', 'Fatz', 'eselwood7p@si.edu', '183 787 7233');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Briant Clarycott', 'T', 'Trunyx', 'bclarycott7q@deliciousdays.com', '864 797 2523');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Isidore Donaldson', 'C', 'Divavu', 'idonaldson7r@youku.com', '410 576 2038');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Aili Starford', 'I', 'Dynava', 'astarford7s@ning.com', '408 521 0289');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carina Samms', 'T', 'Wikizz', 'csamms7t@yahoo.com', '881 186 0194');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leighton Titmuss', 'I', 'Katz', 'ltitmuss7u@fotki.com', '985 719 1318');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vite Flade', 'C', 'Dabjam', 'vflade7v@newyorker.com', '949 813 4949');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ingelbert Hambatch', 'I', 'Fivechat', 'ihambatch7w@cornell.edu', '588 186 4985');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lillis Brome', 'C', 'Myworks', 'lbrome7x@vk.com', '576 561 7869');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hyacintha Stable', 'T', 'Brainsphere', 'hstable7y@opera.com', '793 963 9436');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Staci Donkersley', 'I', 'Eidel', 'sdonkersley7z@chicagotribune.com', '446 610 2462');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kari Balazin', 'T', 'Nlounge', 'kbalazin80@amazonaws.com', '352 458 6402');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Merrily Uzielli', 'I', 'Skilith', 'muzielli81@statcounter.com', '204 989 3688');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sayre Gurys', 'I', 'Vipe', 'sgurys82@howstuffworks.com', '549 966 7827');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Garfield McShirrie', 'I', 'Quimba', 'gmcshirrie83@lycos.com', '695 901 0428');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Billy Fearnyhough', 'T', 'Thoughtbridge', 'bfearnyhough84@sphinn.com', '169 715 8513');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Devin Howselee', 'C', 'Skajo', 'dhowselee85@gmpg.org', '841 529 7984');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Paulina Gummie', 'T', 'Centizu', 'pgummie86@marketwatch.com', '769 190 4509');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Almeria Rosevear', 'I', 'Flipbug', 'arosevear87@dailymotion.com', '989 945 9201');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Galven Anstis', 'C', 'Centimia', 'ganstis88@vk.com', '218 566 2182');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jehanna Peerless', 'I', 'Abata', 'jpeerless89@patch.com', '635 653 5849');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cristina Glavin', 'I', 'Kimia', 'cglavin8a@sina.com.cn', '144 415 8562');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Joscelin Longson', 'C', 'Aibox', 'jlongson8b@uol.com.br', '955 199 0580');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tadd Smittoune', 'T', 'Cogilith', 'tsmittoune8c@csmonitor.com', '146 734 3779');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bernadene Battye', 'I', 'Plajo', 'bbattye8d@hexun.com', '925 379 4519');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Karilynn Nisbet', 'T', 'Rhyzio', 'knisbet8e@homestead.com', '644 296 2431');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Julianne Gillum', 'T', 'Ntags', 'jgillum8f@dedecms.com', '101 502 9161');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Duffy Swatten', 'T', 'Dabshots', 'dswatten8g@virginia.edu', '651 862 0683');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Guglielma Kynan', 'I', 'Tavu', 'gkynan8h@printfriendly.com', '130 713 7041');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Langsdon Solland', 'I', 'Edgewire', 'lsolland8i@cloudflare.com', '636 410 1730');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dacie Klishin', 'C', 'Zooveo', 'dklishin8j@apache.org', '714 299 9970');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Phil Hanselman', 'T', 'DabZ', 'phanselman8k@simplemachines.org', '522 779 7167');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jodi Watchorn', 'I', 'Realbridge', 'jwatchorn8l@nps.gov', '180 587 6562');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Danya Fallen', 'C', 'Trupe', 'dfallen8m@unesco.org', '570 561 4974');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Felizio Grossman', 'T', 'Gabcube', 'fgrossman8n@g.co', '511 622 5101');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clotilda Jorczyk', 'C', 'Zooxo', 'cjorczyk8o@issuu.com', '993 677 8638');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Noami Linden', 'I', 'Tekfly', 'nlinden8p@rakuten.co.jp', '445 207 4949');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Auria Woodgate', 'C', 'Dabshots', 'awoodgate8q@51.la', '387 477 2743');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kennith Schott', 'C', 'Rhynoodle', 'kschott8r@posterous.com', '625 578 3862');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eva Broom', 'C', 'Oyondu', 'ebroom8s@scientificamerican.com', '243 508 9630');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jessi Dayce', 'I', 'Zava', 'jdayce8t@de.vu', '600 917 1686');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ashlie Maybery', 'C', 'Quinu', 'amaybery8u@cyberchimps.com', '846 554 2283');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Symon McGenn', 'C', 'Jabbertype', 'smcgenn8v@photobucket.com', '101 557 3054');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Thedrick Caffery', 'C', 'Edgeclub', 'tcaffery8w@jugem.jp', '964 527 8190');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dorry MacCarter', 'C', 'Trilia', 'dmaccarter8x@geocities.com', '158 886 2303');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Audy McUre', 'C', 'Innotype', 'amcure8y@free.fr', '225 751 1033');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Catherin Blore', 'C', 'Yozio', 'cblore8z@ft.com', '339 397 4726');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hilda Branchett', 'T', 'Kwilith', 'hbranchett90@networksolutions.com', '429 661 4328');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vally Hymor', 'T', 'Vinder', 'vhymor91@privacy.gov.au', '592 860 4398');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kalli Reimer', 'I', 'Gigazoom', 'kreimer92@paginegialle.it', '591 436 8267');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gianna Longhorne', 'I', 'Feedspan', 'glonghorne93@ca.gov', '453 483 2827');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brooke Upham', 'C', 'LiveZ', 'bupham94@icio.us', '716 523 3047');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Graehme Goldup', 'C', 'Babbleset', 'ggoldup95@usnews.com', '340 349 8576');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Selia Dellar', 'I', 'Jaxspan', 'sdellar96@mapy.cz', '420 829 4564');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Annalise Larmet', 'I', 'Agimba', 'alarmet97@blinklist.com', '756 191 4844');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Irita Kemish', 'C', 'Yakidoo', 'ikemish98@myspace.com', '552 448 2067');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Viola Prugel', 'I', 'Yata', 'vprugel99@pinterest.com', '284 488 6293');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Stevie Dodridge', 'C', 'Dynazzy', 'sdodridge9a@arstechnica.com', '475 470 5895');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Orion Alexis', 'I', 'Photojam', 'oalexis9b@sohu.com', '293 881 3674');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Irena de Copeman', 'T', 'Devpoint', 'ide9c@sfgate.com', '418 936 9098');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kerrill Crimes', 'T', 'Realcube', 'kcrimes9d@merriam-webster.com', '936 268 0039');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cobby Stampe', 'C', 'Youbridge', 'cstampe9e@msn.com', '818 373 3975');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nicky Friedman', 'C', 'Topicware', 'nfriedman9f@miibeian.gov.cn', '564 155 8357');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cully Neal', 'I', 'Innojam', 'cneal9g@dell.com', '757 560 2930');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nannette Gerhartz', 'T', 'Wordtune', 'ngerhartz9h@seattletimes.com', '758 424 2606');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jenine Pocock', 'C', 'Ntags', 'jpocock9i@qq.com', '359 449 7858');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winifred Perryman', 'T', 'Realbuzz', 'wperryman9j@indiegogo.com', '592 317 5339');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sylas Delves', 'T', 'Kazu', 'sdelves9k@gmpg.org', '589 831 0946');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emlyn Gauson', 'I', 'Oba', 'egauson9l@youtube.com', '183 657 4612');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Orel Gryglewski', 'C', 'Skinder', 'ogryglewski9m@bloglines.com', '625 150 8036');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Daphne Thripp', 'C', 'Voonyx', 'dthripp9n@tinypic.com', '242 380 9961');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jobi Dyment', 'C', 'Quinu', 'jdyment9o@comsenz.com', '200 441 7608');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Normand Ferraron', 'I', 'Kayveo', 'nferraron9p@ca.gov', '357 468 8172');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raimondo Skellon', 'I', 'JumpXS', 'rskellon9q@hud.gov', '943 277 1218');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Claudian Swansbury', 'T', 'Kamba', 'cswansbury9r@google.ru', '161 380 6900');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Saunderson Doodson', 'T', 'Talane', 'sdoodson9s@opera.com', '612 726 2168');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nikkie Butson', 'C', 'Kwideo', 'nbutson9t@shareasale.com', '213 993 3302');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ofella Donneely', 'I', 'Bubbletube', 'odonneely9u@icq.com', '783 534 6521');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Christal Coche', 'I', 'Vipe', 'ccoche9v@scribd.com', '571 805 5357');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raffaello Kerslake', 'T', 'Yodoo', 'rkerslake9w@moonfruit.com', '815 635 5911');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Violante Guiet', 'C', 'Babbleblab', 'vguiet9x@blogger.com', '662 256 1549');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lin Jancso', 'C', 'Gevee', 'ljancso9y@ow.ly', '804 189 6169');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alyda Scothorne', 'I', 'Gabtune', 'ascothorne9z@youtube.com', '888 380 3215');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Robinet Edworthy', 'T', 'Jatri', 'redworthya0@ox.ac.uk', '468 342 4070');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jilli MacHostie', 'I', 'Oyoyo', 'jmachostiea1@pen.io', '990 309 1979');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Genia Philbin', 'I', 'Bubblemix', 'gphilbina2@slideshare.net', '582 542 5843');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jacky Ewbank', 'T', 'Layo', 'jewbanka3@1688.com', '988 596 8920');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ricardo Devon', 'I', 'Rooxo', 'rdevona4@mtv.com', '600 200 8335');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ric Jeannon', 'I', 'Wikizz', 'rjeannona5@ft.com', '925 339 8826');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pansy Rodda', 'I', 'Skyndu', 'proddaa6@technorati.com', '999 726 4390');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Essie Kiddle', 'I', 'Oozz', 'ekiddlea7@soundcloud.com', '994 918 5581');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mattie Klimkiewich', 'T', 'Trudoo', 'mklimkiewicha8@a8.net', '141 780 4190');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rowan Scruby', 'T', 'Roombo', 'rscrubya9@howstuffworks.com', '990 994 8370');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raynell McAne', 'I', 'Dabfeed', 'rmcaneaa@gmpg.org', '997 120 9130');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emanuel Garlant', 'C', 'Mymm', 'egarlantab@geocities.jp', '718 314 1610');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rex Petris', 'I', 'Tagtune', 'rpetrisac@fastcompany.com', '557 949 3488');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hayyim Lennon', 'C', 'Wikizz', 'hlennonad@prlog.org', '574 574 4019');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Suzanne Shrubshall', 'I', 'Blogpad', 'sshrubshallae@jimdo.com', '187 375 9323');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emlyn Denslow', 'I', 'Fivechat', 'edenslowaf@yahoo.com', '513 538 1320');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Angil Chartre', 'T', 'JumpXS', 'achartreag@discuz.net', '504 361 7649');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Aarika Romain', 'T', 'Jazzy', 'aromainah@clickbank.net', '587 690 9493');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tiler Yarrell', 'C', 'Abatz', 'tyarrellai@list-manage.com', '254 467 8337');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Viki Heardman', 'I', 'Rhynoodle', 'vheardmanaj@seesaa.net', '547 967 6572');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dannye Huguet', 'I', 'Ainyx', 'dhuguetak@army.mil', '961 539 6892');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Davide Marikhin', 'T', 'Brainbox', 'dmarikhinal@weibo.com', '860 578 0191');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Laural Linke', 'I', 'Browsetype', 'llinkeam@pinterest.com', '546 731 7326');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maighdiln Benne', 'C', 'Agimba', 'mbennean@surveymonkey.com', '829 721 7923');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Justinian Didsbury', 'I', 'Dabfeed', 'jdidsburyao@chron.com', '547 266 3736');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lyda Edgcumbe', 'C', 'Eamia', 'ledgcumbeap@sourceforge.net', '420 504 5210');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tersina Antonelli', 'T', 'Feedmix', 'tantonelliaq@independent.co.uk', '403 538 4130');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Andra Normaville', 'C', 'JumpXS', 'anormavillear@ezinearticles.com', '652 151 0344');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Willetta Attryde', 'T', 'Zoozzy', 'wattrydeas@hc360.com', '613 253 6525');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ola Wolstenholme', 'T', 'Photospace', 'owolstenholmeat@icq.com', '429 118 2243');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Feliks Inett', 'I', 'Quimba', 'finettau@apple.com', '999 532 6943');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jerad Scampion', 'C', 'Wikibox', 'jscampionav@va.gov', '633 556 1827');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lauren Brandin', 'I', 'Voonyx', 'lbrandinaw@ibm.com', '884 832 3228');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Guss Olivello', 'I', 'Zoombeat', 'golivelloax@disqus.com', '272 209 2651');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Oliy Juhruke', 'C', 'Shuffledrive', 'ojuhrukeay@amazon.co.jp', '413 531 8733');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hilde Prigg', 'I', 'Devpoint', 'hpriggaz@hugedomains.com', '396 100 3266');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jo ann Haken', 'C', 'Meembee', 'jannb0@prweb.com', '886 577 2879');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winnifred Keetley', 'I', 'Pixoboo', 'wkeetleyb1@google.pl', '395 909 7818');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maurita Sommerton', 'I', 'Eire', 'msommertonb2@illinois.edu', '638 447 0022');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bride Astlett', 'I', 'Tagopia', 'bastlettb3@google.com.hk', '621 915 3149');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Paolina Swales', 'I', 'Divanoodle', 'pswalesb4@hexun.com', '884 162 3925');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Faustina Tunnicliffe', 'C', 'Rhynoodle', 'ftunnicliffeb5@walmart.com', '993 626 3258');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bernhard Legerwood', 'I', 'Eimbee', 'blegerwoodb6@hatena.ne.jp', '750 657 4315');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carley Niesing', 'T', 'Einti', 'cniesingb7@com.com', '919 843 8063');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Abbey Orth', 'T', 'Twimm', 'aorthb8@virginia.edu', '454 564 8170');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berty Prose', 'I', 'Thoughtstorm', 'bproseb9@printfriendly.com', '736 130 2062');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Matthew Harcus', 'T', 'Wikido', 'mharcusba@twitpic.com', '239 287 0408');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Margaretta Menco', 'C', 'Gabcube', 'mmencobb@mapquest.com', '609 522 6484');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Matty Adamo', 'C', 'Jatri', 'madamobc@telegraph.co.uk', '762 282 0438');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Anne-marie Sutliff', 'C', 'Edgewire', 'asutliffbd@rediff.com', '561 693 3078');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ardene Mildenhall', 'I', 'Oozz', 'amildenhallbe@jigsy.com', '161 641 2615');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Romy Philo', 'C', 'Riffpath', 'rphilobf@intel.com', '547 619 0819');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dillie Cleverly', 'I', 'Quaxo', 'dcleverlybg@gravatar.com', '537 518 7784');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marlowe McGettigan', 'C', 'Livetube', 'mmcgettiganbh@spiegel.de', '527 279 3491');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Saraann Mehew', 'I', 'Devify', 'smehewbi@infoseek.co.jp', '647 328 5097');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clemmie Kidner', 'C', 'Rooxo', 'ckidnerbj@hexun.com', '906 331 2096');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leese Alastair', 'C', 'Npath', 'lalastairbk@elegantthemes.com', '788 364 1094');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raynell Dust', 'T', 'Tagopia', 'rdustbl@xinhuanet.com', '122 405 2878');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alphonso Beagan', 'T', 'Aimbu', 'abeaganbm@blogspot.com', '848 699 0193');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rikki Wither', 'I', 'Browsezoom', 'rwitherbn@digg.com', '221 860 8032');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alexei Hornig', 'T', 'Kayveo', 'ahornigbo@columbia.edu', '641 914 3833');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maryanne Buddles', 'T', 'Skiba', 'mbuddlesbp@vkontakte.ru', '763 586 8042');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Egbert Schreiner', 'C', 'Shufflebeat', 'eschreinerbq@hao123.com', '981 480 6607');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pegeen Worlock', 'C', 'InnoZ', 'pworlockbr@1und1.de', '281 324 2684');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Forster Eglese', 'C', 'Bluezoom', 'feglesebs@mlb.com', '615 203 8927');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Friedrich D''Oyly', 'I', 'Youbridge', 'fdoylybt@howstuffworks.com', '375 306 9783');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Johnath Priestman', 'T', 'Feednation', 'jpriestmanbu@zimbio.com', '678 464 0632');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Olivette Filer', 'T', 'Flipopia', 'ofilerbv@pagesperso-orange.fr', '355 123 4486');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carver Patmore', 'I', 'Tagchat', 'cpatmorebw@businessweek.com', '693 778 1052');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Florian Rosenhaus', 'T', 'Gigaclub', 'frosenhausbx@msn.com', '407 840 9719');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sarajane Lilford', 'T', 'Reallinks', 'slilfordby@psu.edu', '356 267 5311');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Earl Farrell', 'C', 'Jabbersphere', 'efarrellbz@tuttocitta.it', '203 334 7182');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vidovik Wellum', 'I', 'Topicshots', 'vwellumc0@rakuten.co.jp', '643 330 1681');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Johnath Bunny', 'I', 'Jaxbean', 'jbunnyc1@ow.ly', '265 902 3568');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Elaina Hooban', 'I', 'Thoughtstorm', 'ehoobanc2@paypal.com', '617 491 0104');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tann Bea', 'T', 'Kwilith', 'tbeac3@altervista.org', '223 938 9733');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sayres Meaney', 'C', 'Topicware', 'smeaneyc4@newsvine.com', '314 621 8128');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jeramie MacCaughen', 'I', 'Skivee', 'jmaccaughenc5@noaa.gov', '965 173 6979');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bridget Oldman', 'T', 'Skipstorm', 'boldmanc6@alibaba.com', '944 292 9444');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leopold Kensall', 'C', 'Photospace', 'lkensallc7@cbslocal.com', '707 278 7963');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Joan Shannon', 'C', 'Feednation', 'jshannonc8@mayoclinic.com', '162 474 8363');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Shamus Sabbatier', 'C', 'Trupe', 'ssabbatierc9@fastcompany.com', '788 394 6280');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gill Leyre', 'T', 'Flashset', 'gleyreca@psu.edu', '915 711 7843');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Stefano Daile', 'T', 'Fatz', 'sdailecb@studiopress.com', '386 317 7488');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dix Charlton', 'I', 'Fivespan', 'dcharltoncc@altervista.org', '405 626 9862');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Harmonia Bresner', 'T', 'Flipbug', 'hbresnercd@51.la', '864 835 3148');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Merrile Wedon', 'T', 'Oyoba', 'mwedonce@senate.gov', '100 317 9975');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chaunce Iffe', 'T', 'Quimm', 'ciffecf@wunderground.com', '794 414 0265');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yolanda Gopsill', 'C', 'Gabvine', 'ygopsillcg@dot.gov', '664 901 7825');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Milt Pratty', 'T', 'Zoomdog', 'mprattych@msn.com', '404 888 2042');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lyssa Forrest', 'T', 'Omba', 'lforrestci@pcworld.com', '551 292 5852');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Corrianne Southon', 'C', 'Quinu', 'csouthoncj@ezinearticles.com', '777 239 7626');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eleanore Scoffins', 'I', 'Zoomzone', 'escoffinsck@bing.com', '269 441 5650');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Olag Giacomoni', 'C', 'Zoonder', 'ogiacomonicl@histats.com', '597 183 9320');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Willi Benettolo', 'C', 'Mybuzz', 'wbenettolocm@imgur.com', '410 531 3969');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sidney Jaume', 'I', 'Gigabox', 'sjaumecn@rambler.ru', '406 423 2764');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gertrudis Deeves', 'T', 'Meezzy', 'gdeevesco@thetimes.co.uk', '612 786 5526');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Zarla Featherstone', 'I', 'Avavee', 'zfeatherstonecp@mozilla.org', '600 394 9788');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emmott Cabrara', 'I', 'Mydeo', 'ecabraracq@soundcloud.com', '583 116 2641');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Demott Gorgen', 'I', 'Quinu', 'dgorgencr@usda.gov', '416 494 0166');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chrysa Gellibrand', 'I', 'Skidoo', 'cgellibrandcs@newsvine.com', '268 166 0155');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barry Postill', 'C', 'Oba', 'bpostillct@earthlink.net', '204 168 5037');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wittie Lovelock', 'C', 'Vinte', 'wlovelockcu@angelfire.com', '577 698 0420');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jaye Agott', 'T', 'Aivee', 'jagottcv@cnn.com', '884 276 8975');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tim Tewkesberry', 'I', 'Skipstorm', 'ttewkesberrycw@istockphoto.com', '502 828 0706');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roselia Brayson', 'C', 'Realfire', 'rbraysoncx@cdc.gov', '220 669 7721');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cesaro Bygreaves', 'T', 'Flipopia', 'cbygreavescy@dyndns.org', '267 893 1089');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cornelle Austen', 'T', 'Brainsphere', 'caustencz@yellowpages.com', '740 868 7548');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emalia Trevallion', 'I', 'Voonder', 'etrevalliond0@dmoz.org', '772 661 5654');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cathlene Cordero', 'T', 'Lazz', 'ccorderod1@flavors.me', '191 754 7140');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cozmo Gayden', 'C', 'Oozz', 'cgaydend2@studiopress.com', '382 644 4835');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Loretta Joselevitch', 'I', 'Jamia', 'ljoselevitchd3@multiply.com', '535 452 4521');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dotty Klampt', 'I', 'Gabtype', 'dklamptd4@indiatimes.com', '472 932 2422');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Casie Jovicic', 'C', 'Blogtags', 'cjovicicd5@ebay.co.uk', '370 644 0675');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Billye Cumbers', 'C', 'Gigaclub', 'bcumbersd6@ow.ly', '967 925 4404');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maureene Hebdon', 'T', 'Yakitri', 'mhebdond7@cocolog-nifty.com', '311 962 7895');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reiko Tombs', 'T', 'Roomm', 'rtombsd8@flickr.com', '702 596 0814');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Witty Josovich', 'C', 'Rhyloo', 'wjosovichd9@abc.net.au', '438 583 8383');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sylas Querrard', 'T', 'Skyble', 'squerrardda@epa.gov', '371 637 2077');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cloe Larkings', 'T', 'Shufflester', 'clarkingsdb@barnesandnoble.com', '604 830 6126');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Erhard Nary', 'T', 'Edgepulse', 'enarydc@fotki.com', '296 487 7268');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rozanna Jiggens', 'T', 'Browsezoom', 'rjiggensdd@networkadvertising.org', '480 674 5497');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eleanora Coyle', 'C', 'Zoomlounge', 'ecoylede@springer.com', '691 667 7242');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marline Kilgrew', 'C', 'Rhycero', 'mkilgrewdf@fda.gov', '993 504 9104');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sorcha Avrashin', 'T', 'Tazz', 'savrashindg@earthlink.net', '310 545 9921');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Teddy McRavey', 'T', 'Ntag', 'tmcraveydh@imageshack.us', '100 588 2784');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Odelia Sayburn', 'T', 'Photobean', 'osayburndi@tripod.com', '191 614 7988');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Natasha McQuode', 'T', 'Ainyx', 'nmcquodedj@oracle.com', '548 275 0629');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marlo Nellies', 'C', 'Quatz', 'mnelliesdk@slashdot.org', '499 515 3911');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gertie Freeborne', 'T', 'Eidel', 'gfreebornedl@simplemachines.org', '535 152 2094');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dmitri Tumioto', 'T', 'Bluejam', 'dtumiotodm@statcounter.com', '245 508 5728');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clovis Listone', 'I', 'Abata', 'clistonedn@dell.com', '976 306 8400');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Derwin Dewsbury', 'C', 'Tagfeed', 'ddewsburydo@ucla.edu', '493 462 7383');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gordie Minear', 'T', 'Skalith', 'gmineardp@bloglines.com', '511 552 6071');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lucias Jermin', 'I', 'Edgeblab', 'ljermindq@elpais.com', '905 594 1351');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tuesday Rainton', 'I', 'Twitterworks', 'traintondr@ocn.ne.jp', '556 697 1536');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wilfrid Douris', 'C', 'Izio', 'wdourisds@seattletimes.com', '176 246 1329');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berthe Giottini', 'I', 'Feedmix', 'bgiottinidt@java.com', '863 947 0951');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dorey Shepton', 'C', 'Yodel', 'dsheptondu@t.co', '733 757 7673');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reggie Whild', 'I', 'Devshare', 'rwhilddv@so-net.ne.jp', '636 425 5970');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Elfreda Winspire', 'C', 'Photobug', 'ewinspiredw@nydailynews.com', '134 395 9129');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Symon Pickwell', 'T', 'Avamba', 'spickwelldx@sourceforge.net', '171 463 7710');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brent Verry', 'T', 'Riffpath', 'bverrydy@furl.net', '571 436 8578');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Karola Whittock', 'C', 'Dabshots', 'kwhittockdz@ft.com', '921 158 4438');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marge Mirfin', 'T', 'Oyondu', 'mmirfine0@buzzfeed.com', '144 107 1056');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ladonna Sinnatt', 'C', 'Cogidoo', 'lsinnatte1@apple.com', '272 301 7888');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ab De la croix', 'I', 'Leenti', 'adee2@eepurl.com', '274 210 5545');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kirbie Weldrake', 'I', 'Katz', 'kweldrakee3@tuttocitta.it', '853 525 3328');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Juana Brannigan', 'C', 'Quamba', 'jbrannigane4@skyrock.com', '500 554 6561');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Noak Robeiro', 'I', 'Yakitri', 'nrobeiroe5@1688.com', '920 978 8241');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Linell Brickell', 'I', 'Eadel', 'lbrickelle6@tripod.com', '254 909 0854');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Buffy Sand', 'T', 'Mynte', 'bsande7@symantec.com', '135 166 7805');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gwen Deacock', 'T', 'Yozio', 'gdeacocke8@youtube.com', '756 646 5950');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Filbert Flarity', 'C', 'Twiyo', 'fflaritye9@wikipedia.org', '538 838 3001');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carlee Bletso', 'C', 'Twimm', 'cbletsoea@chicagotribune.com', '102 918 6886');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lanny Mersh', 'T', 'Devbug', 'lmersheb@free.fr', '493 505 2670');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barry Barrabeale', 'T', 'Quamba', 'bbarrabealeec@mapquest.com', '938 645 0389');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arlen Mannin', 'T', 'Ainyx', 'amannined@sfgate.com', '644 107 0739');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Olva Ahmed', 'I', 'Riffpath', 'oahmedee@google.pl', '126 343 6692');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barry Pierton', 'T', 'Babbleblab', 'bpiertonef@blog.com', '590 367 0611');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Karleen Stuttman', 'T', 'Pixope', 'kstuttmaneg@networksolutions.com', '392 316 1798');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dennet Chittock', 'T', 'Katz', 'dchittockeh@oakley.com', '163 105 6340');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wolf Maudlin', 'C', 'Trudoo', 'wmaudlinei@sourceforge.net', '122 232 8150');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ricca Klaffs', 'I', 'Trudoo', 'rklaffsej@networksolutions.com', '257 221 4421');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Munroe Reville', 'I', 'Fivebridge', 'mrevilleek@google.co.uk', '423 412 6094');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gabey Clarke', 'I', 'Realbridge', 'gclarkeel@nydailynews.com', '867 787 4175');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Zaria Evered', 'T', 'Devpoint', 'zeveredem@zdnet.com', '343 745 6439');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Saraann Adanet', 'I', 'Yoveo', 'sadaneten@cyberchimps.com', '332 511 4627');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Niel Pullinger', 'I', 'Katz', 'npullingereo@storify.com', '223 791 7852');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Audrie McGrail', 'C', 'Oyonder', 'amcgrailep@google.ca', '521 567 0308');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bibbye Wolfer', 'C', 'Aivee', 'bwolfereq@lulu.com', '933 303 2678');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Veda Tremolieres', 'C', 'Lazz', 'vtremoliereser@ovh.net', '830 599 0527');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chiarra Snoding', 'C', 'Lazzy', 'csnodinges@smh.com.au', '451 957 3113');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Annis Treharne', 'T', 'Ntag', 'atreharneet@angelfire.com', '860 367 1031');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nate Kewish', 'I', 'Zoombox', 'nkewisheu@bing.com', '585 569 4527');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pepito Ghilardi', 'I', 'Quatz', 'pghilardiev@fda.gov', '596 610 1533');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ado Doy', 'T', 'Tagpad', 'adoyew@wordpress.org', '692 481 5062');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Allin Cromblehome', 'C', 'DabZ', 'acromblehomeex@imdb.com', '898 453 0179');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lindy O''Dempsey', 'T', 'Riffpedia', 'lodempseyey@hhs.gov', '841 205 3574');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hermine Skelbeck', 'I', 'Fivespan', 'hskelbeckez@dropbox.com', '978 995 9054');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winifield Riepel', 'I', 'Buzzster', 'wriepelf0@bbc.co.uk', '246 998 4670');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Augie Poxton', 'C', 'Muxo', 'apoxtonf1@domainmarket.com', '220 789 1158');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Verge Fattorini', 'T', 'Eazzy', 'vfattorinif2@icio.us', '850 667 6343');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lidia Trassler', 'C', 'Twiyo', 'ltrasslerf3@imageshack.us', '436 731 2406');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Casey Scroggs', 'I', 'Kamba', 'cscroggsf4@ucoz.ru', '613 566 1136');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Delphinia Tremoulet', 'C', 'Agivu', 'dtremouletf5@1688.com', '353 530 1813');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bryna Leather', 'C', 'Demimbu', 'bleatherf6@irs.gov', '773 986 6011');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Venita Gilleson', 'I', 'Flipstorm', 'vgillesonf7@webmd.com', '260 216 9159');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roosevelt Sidnall', 'T', 'Divape', 'rsidnallf8@hexun.com', '602 246 1943');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Candra Mouton', 'T', 'Devpulse', 'cmoutonf9@imdb.com', '324 339 0176');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clywd Sporgeon', 'T', 'Fadeo', 'csporgeonfa@hexun.com', '612 985 6975');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Babbette Sorrel', 'T', 'Eamia', 'bsorrelfb@vimeo.com', '494 135 9875');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Babara Windham', 'C', 'Meetz', 'bwindhamfc@house.gov', '357 481 9692');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kimbra Callard', 'I', 'Agimba', 'kcallardfd@unicef.org', '716 742 6022');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Candie Enrietto', 'C', 'Fiveclub', 'cenriettofe@intel.com', '157 878 2965');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rogerio Tute', 'T', 'Babbleopia', 'rtuteff@bluehost.com', '570 910 2203');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gray Corbishley', 'I', 'Yombu', 'gcorbishleyfg@wired.com', '766 103 5330');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jyoti Ruppeli', 'T', 'Dabtype', 'jruppelifh@mac.com', '656 698 8967');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Esmeralda Thomesson', 'C', 'Lajo', 'ethomessonfi@hexun.com', '561 160 0598');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raoul Tankin', 'T', 'Thoughtmix', 'rtankinfj@com.com', '613 731 1965');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cristen Elderkin', 'T', 'Flashpoint', 'celderkinfk@pbs.org', '702 582 4388');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lucien Segoe', 'C', 'Riffpedia', 'lsegoefl@woothemes.com', '130 138 0565');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chan Gerauld', 'C', 'Flashdog', 'cgerauldfm@gmpg.org', '155 728 1470');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Isaiah Dongall', 'T', 'Twitterlist', 'idongallfn@businessinsider.com', '146 436 8816');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Peg Tankard', 'T', 'Bubblemix', 'ptankardfo@skyrock.com', '599 346 9110');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nicola Koschek', 'T', 'Centidel', 'nkoschekfp@sakura.ne.jp', '924 455 7736');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Crystie Collis', 'C', 'Oyoba', 'ccollisfq@google.nl', '921 736 8587');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hollie Panichelli', 'I', 'Fivebridge', 'hpanichellifr@symantec.com', '696 791 8798');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jocelyn Scardifield', 'I', 'Camido', 'jscardifieldfs@dell.com', '756 723 1377');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marissa Reynish', 'C', 'Zoombox', 'mreynishft@blogs.com', '595 497 7691');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Judye Groveham', 'T', 'Yakijo', 'jgrovehamfu@issuu.com', '101 634 7308');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Irv Cahill', 'I', 'Voonte', 'icahillfv@thetimes.co.uk', '361 275 1148');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Melania Gasperi', 'C', 'Kazio', 'mgasperifw@printfriendly.com', '155 482 4175');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jud Costell', 'C', 'Twitterworks', 'jcostellfx@i2i.jp', '332 835 4567');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reinhard Joselson', 'T', 'Quatz', 'rjoselsonfy@jimdo.com', '908 353 5023');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Waring Nuccitelli', 'I', 'Layo', 'wnuccitellifz@dailymail.co.uk', '203 462 0107');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fanya Cordero', 'I', 'Linklinks', 'fcorderog0@bloomberg.com', '878 987 4132');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Constancia Pettet', 'I', 'Dynabox', 'cpettetg1@blinklist.com', '545 425 0633');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Saw Norcliffe', 'T', 'Jabberbean', 'snorcliffeg2@vistaprint.com', '206 352 2331');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gage Eustes', 'I', 'Skyba', 'geustesg3@prlog.org', '560 803 6205');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kristal Meacher', 'T', 'Wordtune', 'kmeacherg4@discovery.com', '250 554 7066');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Charlton Soda', 'C', 'Mynte', 'csodag5@tmall.com', '235 200 1170');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alyssa Bartalin', 'T', 'Vinder', 'abartaling6@gov.uk', '867 584 2218');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Panchito Bodle', 'T', 'Tavu', 'pbodleg7@dot.gov', '917 246 4576');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adolf Van Dalen', 'T', 'Blogspan', 'avang8@cam.ac.uk', '549 531 0609');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nil Stangoe', 'I', 'Skaboo', 'nstangoeg9@cbslocal.com', '668 198 4811');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bryanty Lippitt', 'T', 'Ozu', 'blippittga@jiathis.com', '195 281 9928');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kelsey Tonge', 'T', 'Livetube', 'ktongegb@reuters.com', '488 146 8805');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Derek Cooling', 'C', 'Kwinu', 'dcoolinggc@jiathis.com', '347 658 2895');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sly Slocum', 'C', 'Dablist', 'sslocumgd@admin.ch', '272 135 8239');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Flynn Culbert', 'C', 'Gabtune', 'fculbertge@exblog.jp', '567 871 4809');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bonnibelle Mowatt', 'T', 'Photolist', 'bmowattgf@example.com', '561 403 6986');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gregory Matthieson', 'T', 'Flipstorm', 'gmatthiesongg@wiley.com', '465 751 1578');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Raphaela Weatherburn', 'I', 'Mybuzz', 'rweatherburngh@ted.com', '920 588 6099');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Manfred Routhorn', 'T', 'Yakidoo', 'mrouthorngi@opera.com', '294 473 3149');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kasey Lazar', 'I', 'Rhyloo', 'klazargj@aboutads.info', '237 551 3479');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reagen Hane', 'T', 'Skimia', 'rhanegk@smh.com.au', '820 416 3147');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Estele Balderson', 'C', 'Meejo', 'ebaldersongl@github.com', '758 794 0950');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Engracia Deaves', 'T', 'Skivee', 'edeavesgm@nhs.uk', '297 225 4235');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nadine Whawell', 'I', 'Tekfly', 'nwhawellgn@addthis.com', '216 606 6033');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Danya Canceller', 'I', 'Ntag', 'dcancellergo@w3.org', '353 869 5267');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arman Joris', 'I', 'Leenti', 'ajorisgp@parallels.com', '598 726 5273');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gualterio Rodinger', 'I', 'Jetpulse', 'grodingergq@mit.edu', '473 427 8187');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Denni Somerlie', 'C', 'Tagcat', 'dsomerliegr@live.com', '753 604 4943');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ashely Blakiston', 'I', 'Plambee', 'ablakistongs@zimbio.com', '786 167 8977');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hal Steinham', 'T', 'Avamba', 'hsteinhamgt@ask.com', '522 233 6868');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chaddy Fittis', 'C', 'Babbleblab', 'cfittisgu@nasa.gov', '572 325 5468');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nert Boynes', 'I', 'Riffpath', 'nboynesgv@webnode.com', '531 571 8213');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sondra Erskin', 'C', 'Voomm', 'serskingw@comcast.net', '432 836 5415');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vivie Corinton', 'C', 'Zoonder', 'vcorintongx@bing.com', '237 981 2830');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gamaliel Heinicke', 'I', 'Devbug', 'gheinickegy@pbs.org', '318 435 5413');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alyss Behne', 'T', 'Yozio', 'abehnegz@cbsnews.com', '378 129 7355');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nollie Sheehy', 'I', 'Leexo', 'nsheehyh0@wisc.edu', '291 557 0292');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nikaniki Wall', 'I', 'Plambee', 'nwallh1@github.io', '626 614 1418');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jarrad Jeannet', 'C', 'Myworks', 'jjeanneth2@slate.com', '698 634 3833');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wilburt Benstead', 'I', 'Skibox', 'wbensteadh3@multiply.com', '219 211 4293');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lezley Savory', 'I', 'Browsecat', 'lsavoryh4@ox.ac.uk', '432 645 7174');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fenelia Trimble', 'I', 'Aivee', 'ftrimbleh5@blogger.com', '301 704 5384');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marthe Tooby', 'I', 'Skimia', 'mtoobyh6@google.com.hk', '237 148 8332');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tymothy Skarr', 'I', 'Dynazzy', 'tskarrh7@jimdo.com', '559 281 2456');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Riccardo Wiltshire', 'C', 'Viva', 'rwiltshireh8@google.ru', '119 415 5216');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nikita Lusted', 'I', 'Jabberstorm', 'nlustedh9@hibu.com', '622 200 4750');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Heath Stathor', 'T', 'Livepath', 'hstathorha@blogspot.com', '719 830 9538');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Granger Swannick', 'I', 'Divavu', 'gswannickhb@liveinternet.ru', '736 677 4754');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Iago Panketh', 'I', 'Oyoyo', 'ipankethhc@yellowpages.com', '625 833 1948');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Susi Dunkerly', 'C', 'Dabvine', 'sdunkerlyhd@imgur.com', '831 635 0422');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Giustino Barca', 'T', 'Wordpedia', 'gbarcahe@statcounter.com', '672 646 7743');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emile Donnellan', 'T', 'Layo', 'edonnellanhf@merriam-webster.com', '617 268 8174');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pepillo Kohrs', 'I', 'Kwilith', 'pkohrshg@opera.com', '584 209 5415');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gill Cecely', 'T', 'Plambee', 'gcecelyhh@dot.gov', '854 440 7993');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marylou Brunicke', 'C', 'Ainyx', 'mbrunickehi@hao123.com', '282 215 6800');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jennifer Leeming', 'T', 'Nlounge', 'jleeminghj@cbsnews.com', '769 822 7341');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Julianne Fedoronko', 'I', 'Dynava', 'jfedoronkohk@dedecms.com', '273 610 3973');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sybil Slowan', 'T', 'Quinu', 'sslowanhl@census.gov', '310 892 5443');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Anne Brailsford', 'I', 'Abata', 'abrailsfordhm@aboutads.info', '941 459 9464');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Georgie Husbands', 'I', 'Babbleblab', 'ghusbandshn@upenn.edu', '205 487 2941');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fara Darrington', 'I', 'Blogspan', 'fdarringtonho@unicef.org', '603 179 1180');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Robinett Harkin', 'T', 'Vitz', 'rharkinhp@businesswire.com', '980 399 2505');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Denver Tuiller', 'I', 'Quinu', 'dtuillerhq@shop-pro.jp', '390 782 5360');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Devonna Gilogly', 'T', 'Photobug', 'dgiloglyhr@biglobe.ne.jp', '705 652 4164');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marnia Rogister', 'I', 'Centizu', 'mrogisterhs@alibaba.com', '950 742 8477');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barney Elverston', 'I', 'Edgeblab', 'belverstonht@ucla.edu', '889 116 0622');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jonah Milstead', 'T', 'Dazzlesphere', 'jmilsteadhu@pbs.org', '249 728 8543');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ira Domke', 'C', 'Skyble', 'idomkehv@foxnews.com', '220 709 9090');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Valentin Casaccio', 'T', 'Mybuzz', 'vcasacciohw@delicious.com', '693 839 8487');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cointon Rosenvasser', 'C', 'Leenti', 'crosenvasserhx@engadget.com', '649 556 2607');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ralina Schiesterl', 'T', 'Riffwire', 'rschiesterlhy@gmpg.org', '882 794 4150');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Derward Pietsma', 'C', 'Realfire', 'dpietsmahz@upenn.edu', '244 130 0959');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rochell Snailham', 'T', 'Kimia', 'rsnailhami0@rediff.com', '753 879 7689');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Althea Bernardotte', 'T', 'Quatz', 'abernardottei1@ow.ly', '892 170 0125');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mamie Monni', 'C', 'Yozio', 'mmonnii2@discovery.com', '453 644 3337');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lolita Manchester', 'I', 'Yambee', 'lmanchesteri3@mail.ru', '214 595 7558');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Borg Jakubczyk', 'C', 'Skinte', 'bjakubczyki4@rambler.ru', '281 377 7411');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maxy Mound', 'I', 'Eadel', 'mmoundi5@people.com.cn', '240 476 6186');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vilma McNabb', 'I', 'Yodoo', 'vmcnabbi6@youtube.com', '168 229 6750');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ellen Chicchetto', 'I', 'Topdrive', 'echicchettoi7@ftc.gov', '353 690 7408');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Aidan Munnion', 'I', 'Zazio', 'amunnioni8@elpais.com', '887 838 5816');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brittni Latour', 'I', 'Devbug', 'blatouri9@addthis.com', '705 233 4868');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vallie Pessler', 'I', 'Livepath', 'vpessleria@google.ca', '152 305 3158');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wendi Paulillo', 'C', 'Riffwire', 'wpaulilloib@aol.com', '329 766 7635');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clarette Broome', 'C', 'Quire', 'cbroomeic@netscape.com', '540 273 3892');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Margette Giacobo', 'C', 'Photobean', 'mgiacoboid@dell.com', '238 669 8898');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Michelle Garm', 'T', 'Gevee', 'mgarmie@amazon.co.jp', '911 465 5831');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ikey Kitteringham', 'C', 'Blogpad', 'ikitteringhamif@studiopress.com', '278 627 6491');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Salvador Dymidowski', 'C', 'Yotz', 'sdymidowskiig@xinhuanet.com', '410 902 4067');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Geralda Pleasaunce', 'I', 'Photobug', 'gpleasaunceih@histats.com', '650 904 6202');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bradney Searson', 'I', 'Photobug', 'bsearsonii@shutterfly.com', '561 820 6558');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adey Sowthcote', 'I', 'Trilith', 'asowthcoteij@patch.com', '792 141 7377');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Calypso Tasseler', 'T', 'Wikibox', 'ctasselerik@blog.com', '971 187 6527');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Daffy Maharey', 'I', 'Voomm', 'dmahareyil@bluehost.com', '619 479 5854');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Madalyn Rhodef', 'I', 'Skinte', 'mrhodefim@vistaprint.com', '283 287 4883');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Paule McBeth', 'I', 'Kwilith', 'pmcbethin@earthlink.net', '259 559 0004');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kylie Batcock', 'T', 'Gigashots', 'kbatcockio@squarespace.com', '916 101 0346');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Syd Saill', 'I', 'Eadel', 'ssaillip@dyndns.org', '628 293 0227');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Morie Sotham', 'I', 'Myworks', 'msothamiq@nps.gov', '802 548 6525');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sherwin Fitzharris', 'C', 'Thoughtworks', 'sfitzharrisir@washington.edu', '874 943 9644');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cordelie Troyes', 'T', 'Lajo', 'ctroyesis@guardian.co.uk', '312 580 7453');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tirrell Gretham', 'I', 'Camimbo', 'tgrethamit@bravesites.com', '261 585 0480');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Graeme Lymer', 'I', 'Innojam', 'glymeriu@newsvine.com', '174 233 0525');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arron Derl', 'T', 'Twitterwire', 'aderliv@privacy.gov.au', '740 498 7652');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Peder Lammas', 'C', 'Aivee', 'plammasiw@harvard.edu', '456 785 5653');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Courtenay Howick', 'T', 'Agimba', 'chowickix@cargocollective.com', '845 282 1328');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Victoir Lorimer', 'T', 'Livepath', 'vlorimeriy@youtu.be', '671 567 4162');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Thain Ben-Aharon', 'C', 'Gabtune', 'tbenaharoniz@narod.ru', '491 989 2069');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Craggy Ickov', 'C', 'Agimba', 'cickovj0@google.de', '639 522 4830');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Albert Tumulty', 'I', 'Tambee', 'atumultyj1@acquirethisname.com', '335 797 9521');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ofella Piatto', 'I', 'Innojam', 'opiattoj2@globo.com', '180 695 6431');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wallis Mellon', 'T', 'Topicblab', 'wmellonj3@list-manage.com', '588 839 7527');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eliza Lorincz', 'T', 'Dablist', 'elorinczj4@icio.us', '717 197 0580');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lauri Lambal', 'T', 'Rhybox', 'llambalj5@salon.com', '564 697 3585');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Edmund Klimek', 'I', 'Gabtype', 'eklimekj6@parallels.com', '965 670 8636');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lauren Van Zon', 'T', 'Topiczoom', 'lvanj7@businesswire.com', '762 795 2573');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dominica Bompass', 'I', 'Aimbo', 'dbompassj8@blinklist.com', '139 344 9530');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Richmond O''Keenan', 'I', 'Fatz', 'rokeenanj9@reverbnation.com', '308 555 9715');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dall Conti', 'C', 'Kayveo', 'dcontija@narod.ru', '950 943 1404');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Trevor Ottawell', 'T', 'Skiba', 'tottawelljb@virginia.edu', '514 235 8388');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Towney Pargent', 'I', 'Gabcube', 'tpargentjc@census.gov', '757 752 7271');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Thibaud Foukx', 'C', 'Fanoodle', 'tfoukxjd@sitemeter.com', '673 743 8010');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sterne Lethlay', 'C', 'Dablist', 'slethlayje@geocities.com', '342 204 5492');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cheslie Dungee', 'C', 'Chatterpoint', 'cdungeejf@narod.ru', '759 931 3761');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Teresita Crust', 'I', 'Jaloo', 'tcrustjg@tumblr.com', '335 991 4155');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yelena Petrolli', 'C', 'Oba', 'ypetrollijh@house.gov', '932 637 0449');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bryn Delamaine', 'C', 'Jabberbean', 'bdelamaineji@github.io', '671 182 5553');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tommy Barraclough', 'I', 'Brightbean', 'tbarracloughjj@blog.com', '549 174 2115');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Meg Windows', 'I', 'Realcube', 'mwindowsjk@eepurl.com', '992 119 0086');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gretal Joseland', 'I', 'Tambee', 'gjoselandjl@amazon.co.uk', '998 651 4236');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alford Hartford', 'I', 'Fadeo', 'ahartfordjm@wordpress.org', '565 323 0660');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Luce McKevin', 'C', 'Zoomlounge', 'lmckevinjn@berkeley.edu', '368 508 9799');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mandel Solomonides', 'T', 'Lajo', 'msolomonidesjo@marketwatch.com', '613 853 8337');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mireielle Farenden', 'T', 'Eimbee', 'mfarendenjp@jimdo.com', '627 291 8966');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marvin Pippard', 'C', 'Jetpulse', 'mpippardjq@amazonaws.com', '927 503 5471');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jere Coleiro', 'C', 'Blogtag', 'jcoleirojr@wsj.com', '938 214 6835');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lian Moakes', 'T', 'Zoomcast', 'lmoakesjs@topsy.com', '146 375 2430');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bonita Knuckles', 'T', 'Jamia', 'bknucklesjt@dailymail.co.uk', '848 977 9066');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Glennis Tertre', 'T', 'Twitterbridge', 'gtertreju@xrea.com', '996 241 8142');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leandra Alexis', 'I', 'Voonder', 'lalexisjv@tumblr.com', '316 387 1195');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maris Leney', 'I', 'Thoughtworks', 'mleneyjw@chron.com', '118 797 5532');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Caitrin Tapin', 'T', 'Photospace', 'ctapinjx@123-reg.co.uk', '817 613 1146');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Odessa Onion', 'I', 'Quaxo', 'oonionjy@squidoo.com', '571 647 3022');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Moise Malafe', 'C', 'Skalith', 'mmalafejz@jigsy.com', '250 941 2898');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tammy Feye', 'C', 'Linkbuzz', 'tfeyek0@vkontakte.ru', '862 276 7879');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marlene Menego', 'I', 'Gabcube', 'mmenegok1@pcworld.com', '946 669 9133');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Martyn Reeders', 'T', 'Edgeclub', 'mreedersk2@epa.gov', '594 972 9476');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Win Aliman', 'C', 'Twitternation', 'walimank3@mapquest.com', '430 211 0309');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jodi Norvill', 'I', 'Skyble', 'jnorvillk4@dropbox.com', '924 865 5942');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dorette Spofforth', 'I', 'Voonte', 'dspofforthk5@behance.net', '789 247 5041');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Shirlee Hamlyn', 'C', 'Dabvine', 'shamlynk6@bloomberg.com', '532 262 6370');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Annabel Dunderdale', 'I', 'Quatz', 'adunderdalek7@jigsy.com', '224 849 4440');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lita Kember', 'C', 'Browsetype', 'lkemberk8@networksolutions.com', '495 814 5745');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jessi Sharphurst', 'I', 'Rhybox', 'jsharphurstk9@scribd.com', '310 443 1611');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Waylen Chauvey', 'C', 'Lajo', 'wchauveyka@businessweek.com', '868 270 7626');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gregorius Connealy', 'I', 'Thoughtsphere', 'gconnealykb@acquirethisname.com', '400 255 3556');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gustie Cliffe', 'T', 'Youopia', 'gcliffekc@elegantthemes.com', '929 967 0344');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kizzee Goldie', 'T', 'Tagtune', 'kgoldiekd@home.pl', '681 172 7596');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Katrine Issacov', 'T', 'Avaveo', 'kissacovke@xrea.com', '727 424 7873');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nonna Roly', 'T', 'Skynoodle', 'nrolykf@blogtalkradio.com', '923 647 7141');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Octavia Montfort', 'C', 'Yotz', 'omontfortkg@youtu.be', '838 288 8364');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roxane Racine', 'C', 'Eare', 'rracinekh@ustream.tv', '400 405 5159');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gamaliel Charlton', 'I', 'Flipstorm', 'gcharltonki@so-net.ne.jp', '690 495 0092');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vidovic Pennycock', 'I', 'Jayo', 'vpennycockkj@oakley.com', '404 138 6040');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Giles Gilchriest', 'C', 'Layo', 'ggilchriestkk@goodreads.com', '704 817 6664');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sondra Wolverson', 'C', 'Blogtag', 'swolversonkl@example.com', '474 734 5386');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Frieda Blinerman', 'T', 'Skivee', 'fblinermankm@multiply.com', '118 678 0926');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Iris Cuddihy', 'C', 'Youspan', 'icuddihykn@stumbleupon.com', '946 997 0294');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sallyann Leggate', 'C', 'Photobean', 'sleggateko@trellian.com', '955 816 0276');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Joanne Darleston', 'I', 'Rhynoodle', 'jdarlestonkp@google.cn', '348 392 9702');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Elysee Eliasen', 'I', 'Aimbu', 'eeliasenkq@cocolog-nifty.com', '959 921 3945');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tandie Carlin', 'C', 'Mybuzz', 'tcarlinkr@discovery.com', '963 842 8853');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leroi Portwain', 'I', 'Dabvine', 'lportwainks@yahoo.com', '385 132 1769');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clark Cornehl', 'C', 'Agimba', 'ccornehlkt@networkadvertising.org', '102 967 6234');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Betta Millard', 'C', 'Zazio', 'bmillardku@mashable.com', '715 687 0217');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Minerva Erskine', 'T', 'Topicshots', 'merskinekv@google.nl', '629 795 5239');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Orelia Mintram', 'C', 'Twiyo', 'omintramkw@skyrock.com', '339 493 3961');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jasmin Pietzke', 'T', 'Zoombox', 'jpietzkekx@unicef.org', '812 550 4051');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kevan Boerder', 'I', 'Yadel', 'kboerderky@behance.net', '385 395 2817');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Michaella Rapaport', 'C', 'Meezzy', 'mrapaportkz@epa.gov', '277 946 5892');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eloisa Hartil', 'C', 'Snaptags', 'ehartill0@google.de', '774 763 1919');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kile Booton', 'T', 'Brainbox', 'kbootonl1@ox.ac.uk', '707 318 6099');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Juli Barthelmes', 'I', 'Ozu', 'jbarthelmesl2@youtube.com', '886 968 1215');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ingamar Aberhart', 'C', 'Jaxbean', 'iaberhartl3@china.com.cn', '717 390 5927');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bennie Zoppo', 'T', 'Leenti', 'bzoppol4@cargocollective.com', '459 994 9212');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Delmar Cumbridge', 'I', 'Bluezoom', 'dcumbridgel5@youtu.be', '595 468 2225');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gabe Noot', 'C', 'Thoughtsphere', 'gnootl6@goo.ne.jp', '822 997 0366');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barnett Levene', 'T', 'Rhynoodle', 'blevenel7@vkontakte.ru', '679 889 9146');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jobie Gotfrey', 'I', 'Yacero', 'jgotfreyl8@goodreads.com', '822 516 0989');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hilton Groves', 'C', 'LiveZ', 'hgrovesl9@skype.com', '339 852 0974');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ingaborg Wickey', 'T', 'Oyoyo', 'iwickeyla@friendfeed.com', '305 897 1941');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Milo Laraway', 'I', 'Rhynoodle', 'mlarawaylb@ed.gov', '784 728 3768');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dwight Carling', 'C', 'Livetube', 'dcarlinglc@google.com.au', '524 736 5626');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Valeda Bastard', 'I', 'Twitterlist', 'vbastardld@fc2.com', '228 921 2848');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reade Presswell', 'C', 'Einti', 'rpresswellle@hhs.gov', '815 643 7428');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chilton Sebley', 'C', 'Jetpulse', 'csebleylf@sogou.com', '452 929 1164');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jessamyn Wanjek', 'I', 'JumpXS', 'jwanjeklg@mlb.com', '870 812 6172');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bryce Chiles', 'T', 'Jabberbean', 'bchileslh@twitter.com', '514 864 8459');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gael Van Rembrandt', 'C', 'Divape', 'gvanli@harvard.edu', '967 498 9165');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Diannne Coltan', 'T', 'Mybuzz', 'dcoltanlj@360.cn', '737 117 5540');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dane Doncom', 'C', 'Twimbo', 'ddoncomlk@meetup.com', '772 990 8054');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kacie Mickan', 'T', 'Jabbersphere', 'kmickanll@shop-pro.jp', '891 652 3776');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rice Bowers', 'I', 'Tagopia', 'rbowerslm@mail.ru', '663 477 2218');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Odo Mattusov', 'I', 'Dynabox', 'omattusovln@reuters.com', '532 174 0285');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Joete Dowzell', 'C', 'Buzzshare', 'jdowzelllo@utexas.edu', '822 932 7778');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Claude Offer', 'C', 'Podcat', 'cofferlp@printfriendly.com', '232 535 0546');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Harmonia McKerrow', 'C', 'Feedmix', 'hmckerrowlq@vkontakte.ru', '782 671 3113');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rudyard Davidzon', 'T', 'Shuffledrive', 'rdavidzonlr@blogs.com', '506 716 5764');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Allyn Brechin', 'T', 'Photobug', 'abrechinls@bloomberg.com', '741 439 4148');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carrie Philo', 'I', 'Eadel', 'cphilolt@furl.net', '364 265 6814');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kristin Copozio', 'C', 'Wikizz', 'kcopoziolu@unesco.org', '754 627 9323');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roby Tonge', 'I', 'Browsezoom', 'rtongelv@bigcartel.com', '264 502 9570');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kellina Seebert', 'C', 'Photofeed', 'kseebertlw@liveinternet.ru', '558 613 1720');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kippy Feacham', 'T', 'Twitternation', 'kfeachamlx@etsy.com', '392 845 0579');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Amalee Dundredge', 'I', 'Tambee', 'adundredgely@behance.net', '164 573 9306');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hamel Vivash', 'C', 'Edgewire', 'hvivashlz@rediff.com', '271 633 3768');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kimberly Fink', 'T', 'Zoombox', 'kfinkm0@hao123.com', '666 607 7257');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Huntlee Loins', 'I', 'Kazu', 'hloinsm1@studiopress.com', '526 553 4484');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Odille Rantoul', 'I', 'Rhyzio', 'orantoulm2@instagram.com', '722 340 0583');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tymon Denys', 'C', 'Gabtune', 'tdenysm3@indiatimes.com', '703 705 2487');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lisetta MacCleod', 'T', 'Topdrive', 'lmaccleodm4@oakley.com', '647 929 8414');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cece Rhydderch', 'T', 'Skajo', 'crhydderchm5@cbslocal.com', '201 628 3512');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Moishe Marrian', 'I', 'Brainbox', 'mmarrianm6@lycos.com', '354 380 2050');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gerhard Lumox', 'C', 'Eimbee', 'glumoxm7@diigo.com', '298 793 3970');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ray Sweeting', 'I', 'Buzzdog', 'rsweetingm8@constantcontact.com', '340 534 1050');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Willard Valiant', 'C', 'Oyoloo', 'wvaliantm9@t.co', '435 331 2906');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rhianon Souster', 'C', 'Tanoodle', 'rsousterma@nasa.gov', '353 655 7080');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jourdain Sargeaunt', 'I', 'Feedfire', 'jsargeauntmb@bing.com', '237 625 9459');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Willy Wilkison', 'I', 'Riffpath', 'wwilkisonmc@biglobe.ne.jp', '962 720 8041');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yancey Fibben', 'C', 'Brightbean', 'yfibbenmd@hc360.com', '161 608 9569');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Roseanne Chellam', 'C', 'Babbleset', 'rchellamme@noaa.gov', '118 284 4604');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barb Britten', 'C', 'Jabbercube', 'bbrittenmf@tiny.cc', '254 924 4906');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Carney Samwyse', 'I', 'Abatz', 'csamwysemg@about.com', '434 740 7798');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barr Piddle', 'I', 'Leenti', 'bpiddlemh@reuters.com', '763 496 6210');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rudolf Ferrieri', 'T', 'Eazzy', 'rferrierimi@elegantthemes.com', '160 238 7859');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ibby Loomis', 'I', 'Edgeify', 'iloomismj@blogger.com', '836 180 8200');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Latashia Danjoie', 'C', 'Aibox', 'ldanjoiemk@china.com.cn', '999 695 5120');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Erny Whittek', 'I', 'Voonix', 'ewhittekml@seattletimes.com', '419 597 2534');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Malissia Cray', 'C', 'Yadel', 'mcraymm@naver.com', '689 362 6175');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Genna Fann', 'I', 'Twitterbridge', 'gfannmn@vimeo.com', '371 169 6299');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Moses Spowart', 'T', 'Photospace', 'mspowartmo@who.int', '426 433 8772');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ludvig Cruttenden', 'I', 'Jabbercube', 'lcruttendenmp@ask.com', '826 159 5458');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Boyce Dreinan', 'T', 'Rhynoodle', 'bdreinanmq@msu.edu', '768 297 3806');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fidelia Fone', 'I', 'Tagopia', 'ffonemr@t.co', '989 455 7187');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Caryl Jaffra', 'T', 'Quamba', 'cjafframs@dedecms.com', '870 194 7842');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Iggie Dobbson', 'C', 'Oyoyo', 'idobbsonmt@nifty.com', '600 512 2326');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Giana Floweth', 'T', 'Zoombox', 'gflowethmu@weebly.com', '778 201 0446');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bondy Brokenshire', 'C', 'Talane', 'bbrokenshiremv@kickstarter.com', '760 177 5338');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fredek Leaburn', 'C', 'Realblab', 'fleaburnmw@bing.com', '470 882 4717');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Asia Lees', 'T', 'Youspan', 'aleesmx@weather.com', '504 355 1809');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Renado Eddow', 'I', 'Innojam', 'reddowmy@gizmodo.com', '380 952 3373');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dominica Shadfourth', 'T', 'Skyndu', 'dshadfourthmz@earthlink.net', '926 822 0557');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mariejeanne Urien', 'C', 'Photobean', 'murienn0@spotify.com', '258 120 1187');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mala Shieber', 'I', 'Skiba', 'mshiebern1@columbia.edu', '509 467 0279');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kayla Gullis', 'I', 'Photobug', 'kgullisn2@merriam-webster.com', '815 435 4809');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Katheryn Crock', 'T', 'Babbleblab', 'kcrockn3@fc2.com', '375 656 3401');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berk Button', 'T', 'Eabox', 'bbuttonn4@csmonitor.com', '682 667 8046');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Garner Saladin', 'C', 'Zoomcast', 'gsaladinn5@uiuc.edu', '155 538 4608');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Amelita Bandiera', 'T', 'Rhyloo', 'abandieran6@cpanel.net', '808 370 0210');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kacy Quarrell', 'T', 'Vidoo', 'kquarrelln7@ifeng.com', '966 340 6900');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Candi MacDonell', 'C', 'Lazz', 'cmacdonelln8@jimdo.com', '338 495 6335');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dorothy Dearness', 'I', 'Layo', 'ddearnessn9@sbwire.com', '119 364 2239');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maura Echelle', 'I', 'Thoughtmix', 'mechellena@about.me', '609 398 4453');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bing Lambarth', 'T', 'Kazu', 'blambarthnb@unblog.fr', '672 433 7379');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fredrick Koppes', 'C', 'Centidel', 'fkoppesnc@icq.com', '989 237 2988');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Felic Kochlin', 'I', 'Katz', 'fkochlinnd@prlog.org', '549 644 1276');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dodi Kunkel', 'T', 'Eabox', 'dkunkelne@phoca.cz', '910 438 4878');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marketa Broggio', 'T', 'Yabox', 'mbroggionf@weather.com', '349 731 5525');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adriena Emma', 'T', 'Meembee', 'aemmang@cargocollective.com', '828 607 6215');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Farley Colgrave', 'C', 'Kwinu', 'fcolgravenh@1und1.de', '743 202 4869');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Haroun Hebden', 'T', 'Wordpedia', 'hhebdenni@51.la', '588 408 1189');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Merrile Shenley', 'I', 'Realbridge', 'mshenleynj@epa.gov', '176 537 8759');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Coralie Andrichuk', 'C', 'Roombo', 'candrichuknk@youku.com', '304 671 5619');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Algernon Aitkin', 'T', 'Edgeblab', 'aaitkinnl@vinaora.com', '511 395 7917');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Maye Jahns', 'T', 'Nlounge', 'mjahnsnm@shareasale.com', '342 815 2040');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kellby Vuitte', 'T', 'Wikizz', 'kvuittenn@timesonline.co.uk', '928 340 4571');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lilyan Pennino', 'I', 'Blogpad', 'lpenninono@newyorker.com', '253 803 8817');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ward Buxey', 'I', 'Eimbee', 'wbuxeynp@mail.ru', '175 384 2328');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mag Upcraft', 'C', 'Linklinks', 'mupcraftnq@uiuc.edu', '789 598 2329');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alissa Daid', 'T', 'Photobug', 'adaidnr@cornell.edu', '426 833 6843');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Nils Presman', 'T', 'Yozio', 'npresmanns@yolasite.com', '158 583 0596');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chevy Ridd', 'I', 'Youspan', 'criddnt@slideshare.net', '280 973 7171');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Herb Regan', 'C', 'Roomm', 'hregannu@boston.com', '509 197 4609');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Herold Struis', 'T', 'Quamba', 'hstruisnv@yahoo.com', '594 626 1454');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Andree Gumley', 'I', 'Vinder', 'agumleynw@webs.com', '113 822 1383');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Baron Gilcrist', 'C', 'Bubblemix', 'bgilcristnx@google.fr', '990 928 5864');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Krishna Bellhanger', 'C', 'Topiclounge', 'kbellhangerny@timesonline.co.uk', '427 838 7301');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Juli Emmer', 'T', 'Youbridge', 'jemmernz@bloglines.com', '162 492 8509');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kamilah Bowser', 'I', 'Realcube', 'kbowsero0@imageshack.us', '856 967 0790');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gwennie Brickstock', 'C', 'Meedoo', 'gbrickstocko1@godaddy.com', '272 771 5736');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bertine Milmoe', 'C', 'Brainverse', 'bmilmoeo2@shop-pro.jp', '659 442 4092');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mirabelle Prester', 'C', 'Oyope', 'mprestero3@slideshare.net', '831 772 8187');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kelby Longfoot', 'T', 'Shufflester', 'klongfooto4@cbslocal.com', '303 629 0526');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kaja Paterson', 'C', 'Pixonyx', 'kpatersono5@tiny.cc', '174 379 8017');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jocelyn Hamilton', 'I', 'Skilith', 'jhamiltono6@cpanel.net', '820 914 9458');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bucky Kelwaybamber', 'I', 'Meevee', 'bkelwaybambero7@prnewswire.com', '543 245 7684');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Emilee Benedict', 'I', 'Gabvine', 'ebenedicto8@canalblog.com', '315 943 9773');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Josselyn Culwen', 'I', 'Mydo', 'jculweno9@stumbleupon.com', '457 177 2077');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Caprice Valder', 'T', 'Jabbersphere', 'cvalderoa@dailymail.co.uk', '329 568 9831');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cahra Klimashevich', 'T', 'Skivee', 'cklimashevichob@imageshack.us', '892 531 8022');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Glenn Huglin', 'I', 'Gigazoom', 'ghuglinoc@washington.edu', '743 445 5090');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berrie Waggitt', 'T', 'Janyx', 'bwaggittod@google.it', '421 593 8691');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ambrose Emerton', 'C', 'Linktype', 'aemertonoe@sitemeter.com', '191 113 0094');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Querida Amner', 'T', 'Linklinks', 'qamnerof@artisteer.com', '889 909 7911');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Izak Ensley', 'I', 'Livefish', 'iensleyog@macromedia.com', '510 102 1623');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Abbye Maw', 'C', 'DabZ', 'amawoh@blinklist.com', '987 692 8486');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jemmy Ansley', 'C', 'Trudoo', 'jansleyoi@cbsnews.com', '977 862 8097');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Robinet Coull', 'I', 'Jabbertype', 'rcoulloj@furl.net', '899 595 8201');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Berni Levane', 'C', 'Mymm', 'blevaneok@histats.com', '807 349 1956');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arden Faich', 'I', 'LiveZ', 'afaichol@simplemachines.org', '960 212 8852');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Alfy Cordell', 'T', 'Aivee', 'acordellom@t.co', '477 528 9890');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Winny Lippard', 'C', 'Wikivu', 'wlippardon@boston.com', '222 627 9772');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Theresita Hadgraft', 'T', 'Jabbercube', 'thadgraftoo@go.com', '861 695 9818');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pepe Chalk', 'I', 'Brainlounge', 'pchalkop@rakuten.co.jp', '977 690 2188');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Horatius Lambdin', 'C', 'Shuffledrive', 'hlambdinoq@nih.gov', '460 959 3705');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Claudell Gorrie', 'I', 'Kaymbo', 'cgorrieor@list-manage.com', '116 818 0609');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bowie Gullifant', 'C', 'Brightbean', 'bgullifantos@paypal.com', '282 704 1379');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chane O''Bradane', 'T', 'Mycat', 'cobradaneot@icq.com', '140 311 0343');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wain Baxstare', 'I', 'Rhybox', 'wbaxstareou@ustream.tv', '231 243 2531');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wendye Maccrae', 'C', 'Camimbo', 'wmaccraeov@icq.com', '172 582 4195');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Jasmin Schafer', 'C', 'Avamm', 'jschaferow@blogtalkradio.com', '448 330 6624');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yolane Dunsmuir', 'C', 'Skimia', 'ydunsmuirox@cnbc.com', '529 586 7145');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clare Grima', 'T', 'Jaxbean', 'cgrimaoy@ebay.co.uk', '253 163 7811');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hamilton Aldcorne', 'C', 'Gabtune', 'haldcorneoz@sakura.ne.jp', '115 940 7365');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bertina Farfull', 'C', 'Thoughtblab', 'bfarfullp0@hubpages.com', '720 660 3458');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kelly Trout', 'T', 'Blognation', 'ktroutp1@woothemes.com', '271 227 4207');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lorettalorna Peever', 'C', 'Fanoodle', 'lpeeverp2@webs.com', '458 961 1956');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reinaldo Handman', 'T', 'Lazzy', 'rhandmanp3@upenn.edu', '168 792 7953');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lanie Ruste', 'I', 'Meezzy', 'lrustep4@prweb.com', '409 983 7827');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Phaedra O''Shiel', 'I', 'Livefish', 'poshielp5@example.com', '998 179 7182');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Irma Lambert', 'T', 'DabZ', 'ilambertp6@yahoo.co.jp', '167 424 5400');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fremont Riccardini', 'C', 'Leexo', 'friccardinip7@alibaba.com', '953 851 4216');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hillery Le - Count', 'T', 'Skipstorm', 'hlep8@linkedin.com', '419 379 5021');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lemmy Trematick', 'T', 'Browsebug', 'ltrematickp9@elpais.com', '780 205 4854');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Oliver Fairpo', 'C', 'Abata', 'ofairpopa@ebay.com', '111 962 2695');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Arabela Serle', 'C', 'Devshare', 'aserlepb@bloglines.com', '113 828 3771');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wynne Everard', 'C', 'Gigazoom', 'weverardpc@admin.ch', '410 466 4714');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wilden Hattam', 'C', 'Realmix', 'whattampd@wired.com', '440 159 9039');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Luella Pinsent', 'I', 'Edgewire', 'lpinsentpe@people.com.cn', '187 210 3173');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cece Paige', 'I', 'Realfire', 'cpaigepf@gravatar.com', '353 947 6714');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Byrom Millea', 'T', 'Npath', 'bmilleapg@163.com', '935 368 1122');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Luisa Baynom', 'C', 'Quimba', 'lbaynomph@va.gov', '731 126 2312');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Denny Messum', 'T', 'Quinu', 'dmessumpi@pen.io', '245 754 2048');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sondra de Marco', 'T', 'Agivu', 'sdepj@ted.com', '163 978 9279');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bryna Lilbourne', 'C', 'Camimbo', 'blilbournepk@time.com', '178 588 9838');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Brooke Bradman', 'I', 'Realbuzz', 'bbradmanpl@bloglovin.com', '227 371 9726');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vitia Gooday', 'I', 'Bluejam', 'vgoodaypm@hc360.com', '288 609 9074');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Trstram Ren', 'C', 'Rhybox', 'trenpn@mozilla.com', '620 353 9956');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gladys Matson', 'I', 'Fatz', 'gmatsonpo@ameblo.jp', '601 995 7823');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Phoebe Sainthill', 'I', 'InnoZ', 'psainthillpp@google.es', '251 574 5322');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Deina Hardwicke', 'C', 'Quatz', 'dhardwickepq@thetimes.co.uk', '287 432 7686');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Ardisj Brislane', 'C', 'Livetube', 'abrislanepr@cam.ac.uk', '827 811 6279');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reinhard Pampling', 'C', 'Fivechat', 'rpamplingps@springer.com', '266 146 4741');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Matelda Raymond', 'C', 'Meemm', 'mraymondpt@weebly.com', '710 202 3165');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Sarene Hoodspeth', 'C', 'Zoovu', 'shoodspethpu@rakuten.co.jp', '859 949 6748');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mischa Newburn', 'I', 'Skimia', 'mnewburnpv@wordpress.org', '917 911 2178');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rey Jiran', 'T', 'Trudeo', 'rjiranpw@chicagotribune.com', '375 465 6589');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Guthrie Olyet', 'T', 'Zooxo', 'golyetpx@sina.com.cn', '678 923 7120');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Merry Jakucewicz', 'T', 'Ainyx', 'mjakucewiczpy@deviantart.com', '802 983 4273');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cozmo Cheyne', 'C', 'Zoomlounge', 'ccheynepz@amazonaws.com', '708 779 6578');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gabie Horrigan', 'C', 'Roodel', 'ghorriganq0@mlb.com', '338 680 3940');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eamon Castelletti', 'C', 'Quamba', 'ecastellettiq1@diigo.com', '958 320 8705');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Wit Gannicleff', 'T', 'Pixonyx', 'wgannicleffq2@state.gov', '714 390 7222');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Leila Dadswell', 'T', 'Babbleset', 'ldadswellq3@prweb.com', '856 129 8103');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tedman Gert', 'T', 'Livetube', 'tgertq4@canalblog.com', '803 400 6089');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Rachel Gianiello', 'C', 'Zoonder', 'rgianielloq5@shinystat.com', '953 614 0496');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Marya Skains', 'T', 'Devpulse', 'mskainsq6@harvard.edu', '407 830 1505');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kristian Letcher', 'T', 'Voonder', 'kletcherq7@techcrunch.com', '483 278 2618');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Giulio Duhig', 'I', 'Tagopia', 'gduhigq8@google.cn', '166 774 7022');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Eric De Cruce', 'T', 'Ooba', 'edeq9@cloudflare.com', '141 969 4542');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Kearney Norcross', 'T', 'Quatz', 'knorcrossqa@unesco.org', '266 929 8517');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chancey Gogan', 'C', 'Aivee', 'cgoganqb@nydailynews.com', '304 879 9932');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Damian Bussey', 'C', 'Avavee', 'dbusseyqc@flickr.com', '964 486 2043');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Aileen Gowrie', 'T', 'Babbleopia', 'agowrieqd@sina.com.cn', '273 391 2465');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Curcio Mather', 'I', 'Rhynyx', 'cmatherqe@oakley.com', '783 761 1210');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cristy McKirton', 'C', 'Voonder', 'cmckirtonqf@amazonaws.com', '313 630 9179');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Flinn Klein', 'C', 'Kaymbo', 'fkleinqg@harvard.edu', '816 609 1226');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Lorianne De Angelo', 'C', 'Photolist', 'ldeqh@nifty.com', '930 759 0365');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Isidora Shellum', 'T', 'Jabbersphere', 'ishellumqi@4shared.com', '255 637 6493');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barrie Stubbley', 'I', 'Camimbo', 'bstubbleyqj@phpbb.com', '711 331 1812');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Chrissie Goulstone', 'I', 'BlogXS', 'cgoulstoneqk@google.com', '340 832 2322');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Deeyn Frost', 'I', 'Kamba', 'dfrostql@arstechnica.com', '989 593 2846');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Fedora Vaughan', 'C', 'Jabbersphere', 'fvaughanqm@cdbaby.com', '855 249 0981');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Hally Knevit', 'C', 'Zoonoodle', 'hknevitqn@discuz.net', '419 310 7794');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Reena Gyer', 'C', 'JumpXS', 'rgyerqo@reddit.com', '680 945 3968');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Val Tenant', 'I', 'Quatz', 'vtenantqp@ow.ly', '360 455 7534');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Seth Oldershaw', 'I', 'Reallinks', 'soldershawqq@w3.org', '486 868 3589');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cissiee Sinnett', 'I', 'Dynabox', 'csinnettqr@ezinearticles.com', '748 453 9633');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cary Haimes', 'C', 'Centimia', 'chaimesqs@geocities.jp', '152 510 0678');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dex Boom', 'T', 'Tagtune', 'dboomqt@naver.com', '692 671 0705');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Zachariah Mewis', 'T', 'Jabbersphere', 'zmewisqu@tiny.cc', '659 158 0095');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Clio Udey', 'T', 'Centimia', 'cudeyqv@elpais.com', '417 328 3460');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Armando Fick', 'C', 'Photobean', 'afickqw@photobucket.com', '323 943 2928');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dita Rumke', 'T', 'Devshare', 'drumkeqx@amazon.co.jp', '570 824 6213');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Domeniga Larwell', 'C', 'Omba', 'dlarwellqy@purevolume.com', '733 925 1144');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Monroe Fernandez', 'T', 'Meemm', 'mfernandezqz@fema.gov', '269 458 8134');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Austine Corre', 'I', 'Quire', 'acorrer0@rakuten.co.jp', '964 894 3789');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cleve Blackham', 'T', 'InnoZ', 'cblackhamr1@google.fr', '763 220 3871');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Skipton Curtayne', 'C', 'Kwilith', 'scurtayner2@mapy.cz', '841 306 2473');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Barclay Fairlamb', 'I', 'Podcat', 'bfairlambr3@aboutads.info', '338 846 1106');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Vikki Bomfield', 'T', 'Zooveo', 'vbomfieldr4@mozilla.com', '891 288 1972');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yule Castri', 'T', 'Quimm', 'ycastrir5@loc.gov', '972 167 8429');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Yolane Greatbanks', 'C', 'Skaboo', 'ygreatbanksr6@webmd.com', '894 205 7347');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Pat Sleight', 'I', 'Quire', 'psleightr7@bloglovin.com', '676 790 5957');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Catha McCarter', 'C', 'Gabtype', 'cmccarterr8@cocolog-nifty.com', '976 375 2116');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Gay Daubney', 'I', 'LiveZ', 'gdaubneyr9@dagondesign.com', '299 640 2184');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cyril Clutterham', 'T', 'Linkbridge', 'cclutterhamra@mashable.com', '785 787 4954');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Adrianna Tuhy', 'C', 'Gabvine', 'atuhyrb@state.tx.us', '211 161 1250');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Annmaria Petricek', 'C', 'Cogibox', 'apetricekrc@berkeley.edu', '318 544 0405');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Issiah Dome', 'C', 'Roombo', 'idomerd@timesonline.co.uk', '901 769 8557');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Edsel Slott', 'T', 'Flipbug', 'eslottre@state.tx.us', '710 719 9090');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Grayce Povey', 'I', 'Flipbug', 'gpoveyrf@deliciousdays.com', '964 936 9036');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Dehlia Gorstidge', 'T', 'Yamia', 'dgorstidgerg@e-recht24.de', '236 459 4217');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Tanny Jeenes', 'I', 'Lazz', 'tjeenesrh@cnn.com', '327 247 3132');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Evvie Fusco', 'T', 'Topicware', 'efuscori@a8.net', '543 807 5591');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Courtney MacLardie', 'C', 'Snaptags', 'cmaclardierj@oakley.com', '507 393 2520');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Zacharias Fisbey', 'I', 'Gabtune', 'zfisbeyrk@mail.ru', '394 252 1902');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Cortie Norres', 'I', 'Zoombeat', 'cnorresrl@rambler.ru', '226 868 9123');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Mariam Kennford', 'T', 'Linkbuzz', 'mkennfordrm@meetup.com', '304 663 3250');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Anastassia Joyes', 'C', 'Babbleopia', 'ajoyesrn@creativecommons.org', '600 244 1276');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Skippy Beggan', 'T', 'Mydeo', 'sbegganro@dyndns.org', '403 858 2293');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Bari Shewsmith', 'I', 'Centidel', 'bshewsmithrp@ning.com', '759 197 8706');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Robinson Ouldcott', 'C', 'Ailane', 'rouldcottrq@privacy.gov.au', '756 276 4156');
insert into Users.users (user_full_name, user_type, user_company_name, user_email, user_phone_number) values ('Juliana Hackford', 'I', 'Dablist', 'jhackfordrr@yale.edu', '631 720 1409');

go


 ---2.2 roles de usuario   12 
INSERT INTO Users.roles (role_name) VALUES ('Agente de reservas');
INSERT INTO Users.roles (role_name) VALUES ('masajista');
INSERT INTO Users.roles (role_name) VALUES ('Recepcionista');
INSERT INTO Users.roles (role_name) VALUES ('Camarero');
INSERT INTO Users.roles (role_name) VALUES ('Seguridad');
INSERT INTO Users.roles (role_name) VALUES ('Mantenimiento');
INSERT INTO Users.roles (role_name) VALUES ('Técnico');
INSERT INTO Users.roles (role_name) VALUES ('Cliente Regular');
INSERT INTO Users.roles (role_name) VALUES ('Cliente VIP');
INSERT INTO Users.roles (role_name) VALUES ('Huésped');
INSERT INTO Users.roles (role_name) VALUES ('Visitante');
INSERT INTO Users.roles (role_name) VALUES ('Turista');
INSERT INTO Users.roles (role_name) VALUES ('Invitado');
INSERT INTO Users.roles (role_name) VALUES ('Cliente de Negocios');
INSERT INTO Users.roles (role_name) VALUES ('Cliente de Eventos');
INSERT INTO Users.roles (role_name) VALUES ('Cliente de Vacaciones');
INSERT INTO Users.roles (role_name) VALUES ('Cliente de Lujo');
go

 ---2.3  perfil de usuario  13

insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-10-19', 'Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-10-30', 'Software Consultant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-12-09', 'Paralegal', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-11-28', 'Administrative Assistant III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-12-02', 'Quality Control Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-08-13', 'Data Coordinator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-11-08', 'Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-09-15', 'Research Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-08-01', 'Account Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-06-18', 'Environmental Tech', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-11-15', 'Payment Adjustment Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-11-13', 'Geologist I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-06-28', 'Geologist III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-10-01', 'Business Systems Development Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-12-25', 'Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-06-19', 'Chemical Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-12-07', 'Project Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-08-23', 'Cost Accountant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-01-06', 'VP Sales', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-05-29', 'Senior Developer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-04-19', 'Systems Administrator II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-01-12', 'Research Assistant IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-10-03', 'Administrative Officer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-07-09', 'Editor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-09-28', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-03-18', 'Internal Auditor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-08-02', 'GIS Technical Architect', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-09-15', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-04-27', 'Programmer I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-01-08', 'Help Desk Technician', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-03-04', 'Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-11-27', 'Biostatistician I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-05-18', 'Desktop Support Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-30', 'GIS Technical Architect', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-12-28', 'Statistician II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-11-19', 'VP Quality Control', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-08-13', 'General Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-07-19', 'Legal Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-10-18', 'Accountant III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-07-02', 'Analyst Programmer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-02-16', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-10-28', 'Research Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-10-16', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-04-25', 'Director of Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-08-10', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-10-31', 'VP Marketing', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-10-30', 'Recruiter', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-03-10', 'Statistician I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-04-04', 'Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-06-14', 'Research Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-08-15', 'Developer IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-01-04', 'Safety Technician IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-02-08', 'Civil Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-04-29', 'Internal Auditor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-01-25', 'Research Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-08-28', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-03-14', 'Systems Administrator II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-05-02', 'Senior Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-06-14', 'Budget/Accounting Analyst I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-02-11', 'Librarian', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-08-10', 'Pharmacist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-03-30', 'Software Test Engineer III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-05-19', 'Quality Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-01-04', 'Human Resources Assistant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-06-14', 'Marketing Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-11-05', 'Junior Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-03-18', 'Human Resources Assistant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-05-26', 'Safety Technician II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-02', 'Human Resources Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-09-07', 'Assistant Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-01-22', 'Office Assistant III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-07-21', 'Computer Systems Analyst II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-08-12', 'Senior Editor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-01-27', 'Safety Technician III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-02-11', 'Quality Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-08-12', 'Teacher', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-06-27', 'Environmental Tech', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-25', 'Food Chemist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-12-18', 'VP Marketing', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-09-05', 'Project Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-07-06', 'Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-12-23', 'Occupational Therapist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-08-24', 'Programmer Analyst IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-12-01', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-01-02', 'Executive Secretary', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-02-06', 'Health Coach I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-10-24', 'Electrical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-01-29', 'Marketing Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-07-05', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-04-29', 'Environmental Tech', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-02-04', 'Marketing Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-07-27', 'Software Test Engineer I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-08-20', 'Media Manager II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-06-27', 'Registered Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-01-21', 'Analog Circuit Design manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-03-01', 'Help Desk Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-08-11', 'Associate Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-02-29', 'Automation Specialist III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-08-03', 'Librarian', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-09-20', 'Project Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-03-17', 'Marketing Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-05-18', 'Human Resources Assistant I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-07-06', 'Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-08-23', 'Internal Auditor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-02-06', 'Automation Specialist III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-11-24', 'Speech Pathologist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-11-21', 'Information Systems Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-05-19', 'Mechanical Systems Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-09-20', 'Project Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-05-02', 'Compensation Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-04-01', 'Marketing Assistant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-05-08', 'Human Resources Assistant I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-11-24', 'Director of Sales', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-05-23', 'Dental Hygienist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-10-12', 'Librarian', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-01-24', 'Account Representative III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-01-19', 'Community Outreach Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-07-03', 'Software Engineer I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-09-14', 'Accountant I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-04-19', 'Paralegal', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-10-06', 'Marketing Assistant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-02-16', 'Physical Therapy Assistant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-05-06', 'Senior Developer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-10-04', 'Assistant Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-03-05', 'Product Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-10-08', 'Geological Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-10-07', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-03-07', 'Business Systems Development Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-02-12', 'Chief Design Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-02-05', 'Junior Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-04-29', 'Tax Accountant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-10-22', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-01-10', 'Clinical Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-06-15', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-01-09', 'Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-03-18', 'Account Coordinator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-09-04', 'Graphic Designer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-03-14', 'Budget/Accounting Analyst I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-04-30', 'Environmental Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-13', 'Human Resources Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-12-04', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-05-07', 'Director of Sales', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-07-31', 'Editor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-02-09', 'Mechanical Systems Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-12-28', 'Business Systems Development Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-12-10', 'Media Manager I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-06-24', 'Recruiter', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-09-13', 'Librarian', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-02-10', 'Physical Therapy Assistant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-02-15', 'Programmer IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-11-01', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-11-01', 'Assistant Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-04-04', 'Nurse Practicioner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-01-23', 'Associate Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-03-12', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-08-26', 'Community Outreach Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-03-26', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-24', 'Senior Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-04-28', 'Executive Secretary', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-04-29', 'Compensation Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-01-16', 'VP Accounting', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-09-24', 'Quality Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-02-27', 'Analog Circuit Design manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-05-26', 'Graphic Designer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-05-16', 'Recruiting Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-05-09', 'Senior Sales Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-08', 'Legal Assistant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-06-29', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-03-24', 'Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-07-26', 'Recruiting Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-07-18', 'Librarian', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-08-27', 'Human Resources Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-07-31', 'Teacher', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-01-23', 'Help Desk Operator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-11-23', 'Actuary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-02-13', 'Tax Accountant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-05-05', 'Social Worker', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-11-27', 'Chief Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-11-16', 'Database Administrator II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-08-16', 'Structural Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-06-09', 'Sales Representative', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-12-11', 'Chemical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-11-05', 'Cost Accountant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-10-10', 'Programmer II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-12-15', 'Safety Technician II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-02-06', 'Graphic Designer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-05-22', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-09-22', 'Project Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-03-11', 'Information Systems Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-06-26', 'Accounting Assistant III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-05-19', 'VP Sales', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-12-26', 'Programmer III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-03-02', 'Recruiting Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-09-25', 'Analyst Programmer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-10-12', 'Business Systems Development Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-03-16', 'Health Coach II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-02', 'Community Outreach Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-03-22', 'Product Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-03-19', 'Structural Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-02-22', 'Environmental Tech', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-10-20', 'Associate Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-06-28', 'Assistant Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-06-01', 'Senior Developer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-07-18', 'Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-11-12', 'Structural Analysis Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-05-30', 'Help Desk Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-11', 'Staff Accountant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-12-01', 'Computer Systems Analyst I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-02-14', 'Nuclear Power Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-01-17', 'Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-11-16', 'VP Quality Control', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-08-14', 'Mechanical Systems Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-03-17', 'Director of Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-09-04', 'Product Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-03-21', 'Geologist III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-11-16', 'Community Outreach Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-08-12', 'Nurse Practicioner', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-06-25', 'Quality Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-03-23', 'Account Representative I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-02-17', 'Physical Therapy Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-02-15', 'Administrative Assistant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-10-26', 'VP Quality Control', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-10-03', 'Community Outreach Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-09-20', 'Tax Accountant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-03-23', 'Automation Specialist I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-09-25', 'Marketing Assistant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-07-27', 'Media Manager IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-11-09', 'Graphic Designer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-02-07', 'Research Assistant III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-12-03', 'Chief Design Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-11-11', 'Accountant III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-07-06', 'Structural Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-01-06', 'Senior Cost Accountant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-03-10', 'Accountant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-07-30', 'Desktop Support Technician', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-08-03', 'Quality Control Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-11-14', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-18', 'Engineer III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-25', 'Product Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-09-08', 'Recruiting Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-04-05', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-09-08', 'Human Resources Assistant II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-05-19', 'Director of Sales', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-03-29', 'Chief Design Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-07-28', 'Financial Advisor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-08-03', 'Tax Accountant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-12-19', 'Senior Quality Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-05-25', 'Associate Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-09-22', 'Software Consultant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-08-12', 'Cost Accountant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-03-07', 'Senior Financial Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-06-18', 'GIS Technical Architect', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-01-11', 'Human Resources Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-02-12', 'Software Engineer III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-12-29', 'VP Quality Control', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-09-07', 'Engineer IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-07-15', 'Research Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-12-02', 'Analyst Programmer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-05-27', 'Web Developer III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-04-22', 'Research Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-01-03', 'VP Quality Control', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-09-28', 'Account Representative I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-07-21', 'GIS Technical Architect', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-10-18', 'Actuary', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-04-20', 'Technical Writer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-04-07', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-11-10', 'Cost Accountant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-11-25', 'Administrative Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-11-07', 'Research Associate', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-06-18', 'Media Manager II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-10-18', 'Software Test Engineer II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-02-27', 'Marketing Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-07-17', 'Accounting Assistant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-07-18', 'Electrical Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-10-31', 'Account Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-04-23', 'Account Representative II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-08-22', 'Engineer II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-10-10', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-08-04', 'Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-04-18', 'Senior Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-18', 'Financial Advisor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-05-20', 'Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-05-07', 'Accounting Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-07-10', 'Director of Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-01-18', 'Recruiting Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-09-04', 'Chemical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-02-12', 'Structural Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-08', 'Paralegal', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-11-25', 'Mechanical Systems Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-12-17', 'GIS Technical Architect', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-03-03', 'Operator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-08-22', 'Structural Analysis Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-12-12', 'VP Quality Control', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-01-04', 'Community Outreach Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-10-28', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-08-26', 'VP Sales', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-10-08', 'Social Worker', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-03-15', 'Statistician I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-08-28', 'Civil Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-03-22', 'Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-10-22', 'Account Representative I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-08-05', 'General Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-10-21', 'Registered Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-07-08', 'Senior Sales Associate', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-12-17', 'Desktop Support Technician', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-10-17', 'Senior Financial Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-12-28', 'Health Coach II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-07-24', 'Actuary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-07-29', 'Statistician I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-09-01', 'Compensation Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-05-21', 'Systems Administrator IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-11-13', 'Occupational Therapist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-11-21', 'Chief Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-11-04', 'Research Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-04-02', 'Account Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-03-12', 'Statistician IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-09-28', 'Programmer Analyst III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-04-01', 'Help Desk Technician', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-01-11', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-07-15', 'Recruiting Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-06-29', 'Software Engineer III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-11-30', 'Dental Hygienist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-10-27', 'Marketing Assistant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-08-26', 'Junior Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-08-05', 'Research Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-02-02', 'Assistant Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-01-03', 'Desktop Support Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-07-29', 'Physical Therapy Assistant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-12-29', 'Recruiter', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-04-11', 'Paralegal', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-12-11', 'Quality Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-09-28', 'Geological Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-12-29', 'VP Marketing', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-03-15', 'Research Assistant I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-08-25', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-08-09', 'Media Manager IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-09-14', 'Product Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-05-14', 'Account Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-01-12', 'Registered Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-04-02', 'Engineer IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-07-03', 'Help Desk Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-02-28', 'Financial Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-03-25', 'Accounting Assistant II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-06-20', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-04-20', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-09-14', 'VP Quality Control', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-10-01', 'Accounting Assistant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-05-31', 'Research Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-09-30', 'Junior Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-09-30', 'Geological Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-07-19', 'Environmental Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-10-21', 'Civil Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-30', 'Pharmacist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-10-03', 'Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-05-28', 'Software Consultant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-08-02', 'Compensation Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-07-11', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-07-11', 'Software Engineer I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-05-01', 'Financial Advisor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-01-16', 'Assistant Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-11-01', 'Research Assistant I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-02-18', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-12-30', 'Quality Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-06-21', 'Environmental Tech', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-03-23', 'Community Outreach Specialist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-02-16', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-01-10', 'Chief Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-10-26', 'Nuclear Power Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-07-14', 'Analog Circuit Design manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-03-09', 'Payment Adjustment Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-08-14', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-12-08', 'Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-01-15', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-11-17', 'Developer I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-03-27', 'Assistant Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-07-13', 'Biostatistician II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-11-12', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-02-03', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-25', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-01-17', 'Staff Accountant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-04-24', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-08-15', 'Senior Sales Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-07-28', 'Civil Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-11-20', 'Payment Adjustment Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-12-24', 'Chemical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-05-21', 'Desktop Support Technician', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-10-22', 'Assistant Media Planner', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-03-26', 'Developer I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-10-24', 'Compensation Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-06-12', 'Help Desk Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-05-16', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-04-29', 'Programmer Analyst IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-01-15', 'Recruiting Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-12-14', 'Business Systems Development Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-09-20', 'Media Manager I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-12-25', 'Analyst Programmer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-06-23', 'Financial Advisor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-05-31', 'Director of Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-04-27', 'Administrative Officer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-08-15', 'Accounting Assistant II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-05-07', 'Automation Specialist I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-06-19', 'Assistant Media Planner', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-03-16', 'General Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-05-29', 'Community Outreach Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-05-16', 'Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-05-08', 'Analog Circuit Design manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-07-04', 'Recruiter', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-04-23', 'Structural Analysis Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-01-23', 'Food Chemist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-04-19', 'Recruiting Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-05-09', 'Staff Scientist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-12-05', 'Geologist II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-02-02', 'Technical Writer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-12-09', 'Senior Developer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-09-20', 'Engineer I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-11-01', 'Paralegal', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-02-08', 'Programmer Analyst I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-03-20', 'GIS Technical Architect', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-10-31', 'Associate Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-03-19', 'Sales Representative', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-12-27', 'Accountant III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-01-07', 'Occupational Therapist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-03-26', 'Database Administrator IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-03-20', 'Automation Specialist I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-05-16', 'Actuary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-09-30', 'Speech Pathologist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-11-05', 'Executive Secretary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-12-22', 'Accounting Assistant I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-11-14', 'Information Systems Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-05-24', 'Marketing Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-11-05', 'Tax Accountant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-04-19', 'Help Desk Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-10-30', 'Data Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-04-04', 'Biostatistician IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-06-12', 'Quality Control Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-08-15', 'Budget/Accounting Analyst I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-01-15', 'Senior Quality Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-07-07', 'Registered Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-02-10', 'Payment Adjustment Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-09-01', 'Internal Auditor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-12', 'Marketing Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-11-13', 'Analyst Programmer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-08-25', 'Assistant Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-10-09', 'Cost Accountant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-03-08', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-07-11', 'Developer IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-03-15', 'General Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-11-08', 'Software Consultant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-04-22', 'Senior Developer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-05-08', 'Help Desk Operator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-11-12', 'Assistant Media Planner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-12-29', 'Cost Accountant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-06-09', 'Clinical Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-07-20', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-10-23', 'Assistant Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-12-19', 'VP Accounting', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-10-15', 'Associate Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-03-16', 'Statistician II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-11-13', 'Systems Administrator III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-05-12', 'VP Accounting', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-07-19', 'Nuclear Power Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-08-19', 'Recruiter', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-07-28', 'Budget/Accounting Analyst II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-08-06', 'VP Product Management', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-08-10', 'Office Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-07-14', 'Safety Technician III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-04-25', 'Analog Circuit Design manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-12-22', 'Clinical Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-09-13', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-03-23', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-08-02', 'Chemical Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-10-11', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-01-28', 'Pharmacist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-06-05', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-07-15', 'Graphic Designer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-09-03', 'Environmental Tech', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-03-11', 'Marketing Assistant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-03-09', 'Data Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-03-29', 'Structural Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-05-03', 'Senior Sales Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-12-09', 'Research Assistant III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-10-02', 'Health Coach II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-02-28', 'Programmer Analyst I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-11-28', 'Safety Technician III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-06-16', 'Health Coach III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-07-19', 'Registered Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-08-12', 'Human Resources Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-03-21', 'Business Systems Development Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-09-12', 'Desktop Support Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-01-13', 'Media Manager II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-08-31', 'Nuclear Power Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-08-10', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-08-14', 'Compensation Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-07-19', 'Engineer III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-02-08', 'Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-03-14', 'Research Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-03-29', 'Administrative Officer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-09-10', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-08-22', 'Executive Secretary', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-05-13', 'Technical Writer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-02-12', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-07-26', 'Automation Specialist III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-01-31', 'Quality Control Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-07-12', 'Environmental Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-01-29', 'Clinical Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-02-14', 'Information Systems Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-06-30', 'Food Chemist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-07-19', 'Senior Quality Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-04-20', 'Automation Specialist II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-12-28', 'Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-05-31', 'Financial Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-12-28', 'Analog Circuit Design manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-12', 'Business Systems Development Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-05-24', 'VP Accounting', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-03-03', 'Structural Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-12-24', 'Senior Sales Associate', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-10-17', 'Geologist II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-05-14', 'Occupational Therapist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-04-10', 'Product Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-12-12', 'Senior Editor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-02-17', 'Software Engineer II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-01-06', 'Software Consultant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-09-16', 'Developer IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-10-16', 'Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-03-22', 'Recruiting Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-05-01', 'Information Systems Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-02-11', 'Executive Secretary', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-13', 'Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-01-07', 'VP Marketing', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-03-17', 'Junior Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-06-27', 'Recruiter', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-12-28', 'Account Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-09-23', 'Cost Accountant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-10-06', 'Civil Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-11-14', 'Safety Technician I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-04-17', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-05-06', 'Recruiting Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-02-14', 'Recruiting Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-02-16', 'Media Manager I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-04-13', 'Internal Auditor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-02-26', 'Civil Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-09-04', 'VP Quality Control', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-08-24', 'Food Chemist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-08-16', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-03-01', 'Research Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-04-24', 'Programmer IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-08-24', 'Teacher', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-03-23', 'Programmer Analyst III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-09-27', 'Business Systems Development Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-08-08', 'Programmer III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-09-26', 'Research Assistant I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-12-05', 'Administrative Officer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-04-26', 'Statistician III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-05-12', 'Environmental Tech', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-01-11', 'Paralegal', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-02-26', 'Software Engineer III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-02-28', 'Statistician IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-03-30', 'Clinical Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-10-31', 'Financial Analyst', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-02-12', 'Nuclear Power Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-01-09', 'Executive Secretary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-06-04', 'Accountant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-01-06', 'Biostatistician I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-04-30', 'Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-02-07', 'Food Chemist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-06-22', 'Safety Technician III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-07-30', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-05-05', 'Safety Technician IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-04-30', 'Engineer IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-03-20', 'Geologist II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-10-24', 'Desktop Support Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-04-15', 'Research Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-05-11', 'Librarian', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-11-25', 'Associate Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-12-12', 'Recruiter', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-01-15', 'Programmer IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-02-22', 'Accounting Assistant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-03-30', 'Software Engineer IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-06-06', 'Nurse Practicioner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-08-02', 'Physical Therapy Assistant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-09-17', 'Food Chemist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-05-19', 'Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-10-30', 'Administrative Assistant III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-05-02', 'Assistant Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-01-14', 'Assistant Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-01-03', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-06-06', 'Engineer I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-12-31', 'Research Assistant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-05-18', 'Geologist III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-02-07', 'Teacher', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-01-27', 'Social Worker', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-01-27', 'Paralegal', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-03-05', 'Statistician III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-11-29', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-11-25', 'Geological Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-02', 'Information Systems Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-04-18', 'Automation Specialist I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-01-04', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-06-24', 'Financial Advisor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-09-25', 'Staff Accountant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-12-02', 'Payment Adjustment Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-03-21', 'Product Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-02-14', 'Design Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-08-07', 'Account Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-03-26', 'Health Coach II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-03-13', 'Senior Sales Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-12-22', 'Design Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-01-28', 'Database Administrator III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-02-22', 'Help Desk Operator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-10-03', 'Software Engineer II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-04-17', 'GIS Technical Architect', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-10-01', 'Librarian', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-01-01', 'Speech Pathologist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-01-19', 'Senior Developer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-01-12', 'Payment Adjustment Coordinator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-04-26', 'Clinical Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-21', 'Programmer IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-01-27', 'Administrative Assistant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-06-02', 'Software Engineer III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-10-23', 'Product Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-02-07', 'Legal Assistant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-03-29', 'Food Chemist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-10-12', 'VP Marketing', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-02-15', 'Cost Accountant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-02-16', 'Help Desk Operator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-07-23', 'Quality Control Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-04-28', 'Software Consultant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-12-17', 'Safety Technician II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-09-30', 'Geological Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-06-24', 'Automation Specialist I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-10-19', 'VP Quality Control', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-08-01', 'Geological Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-03-17', 'Database Administrator II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-05-21', 'Director of Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-12-20', 'Legal Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-02-05', 'Help Desk Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-02-23', 'Engineer II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-09-07', 'Data Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-01-21', 'Clinical Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-10-18', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-11-30', 'Junior Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-12-09', 'Project Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-08-28', 'Quality Control Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-05-02', 'Executive Secretary', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-07-15', 'Geologist III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-06-05', 'Data Coordinator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-11-01', 'Senior Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-06-23', 'Web Developer II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-10-29', 'Health Coach IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-09-19', 'Marketing Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-07-30', 'Registered Nurse', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-03-14', 'Cost Accountant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-02-02', 'Accountant III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-06-09', 'Data Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-03-28', 'Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-11-06', 'Nurse Practicioner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-08', 'Accounting Assistant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-07-27', 'Human Resources Assistant III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-01-07', 'Media Manager II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-01-24', 'Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-01-01', 'Food Chemist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-02-08', 'Research Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-06-16', 'Teacher', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-06-01', 'Dental Hygienist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-09-01', 'Software Test Engineer I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-02-10', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-02-04', 'Administrative Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-10-12', 'Speech Pathologist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-12-16', 'Assistant Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-12', 'Staff Accountant III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-07-08', 'Administrative Officer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-11-28', 'Staff Scientist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-08-19', 'Environmental Tech', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-05-26', 'Senior Sales Associate', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-01-29', 'Clinical Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-07-27', 'Software Test Engineer II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-11-19', 'Speech Pathologist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-01-15', 'Staff Accountant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-01-20', 'Web Designer I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-07-28', 'Help Desk Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-05-31', 'Quality Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-04-07', 'Assistant Media Planner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-08-27', 'Operator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-09-05', 'Chief Design Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-09-19', 'Programmer II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-10-30', 'Help Desk Operator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-10-15', 'Recruiter', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-09', 'Librarian', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-03-07', 'Senior Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-01-19', 'Software Consultant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-01-27', 'Business Systems Development Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-04-22', 'Engineer III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-07-25', 'Mechanical Systems Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-02-11', 'Accountant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-12-24', 'VP Marketing', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-11-13', 'Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-15', 'Sales Representative', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-10-07', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-12-23', 'Nuclear Power Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-01-12', 'Database Administrator III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-01-16', 'Software Engineer I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-08-19', 'Developer I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-11-13', 'Health Coach II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-05-29', 'Graphic Designer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-01-30', 'Cost Accountant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-04-05', 'Registered Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-12-30', 'Environmental Tech', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-11-18', 'Geologist IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-05-06', 'Mechanical Systems Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-11-11', 'VP Product Management', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-04-15', 'Safety Technician III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-05-24', 'Social Worker', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-01-05', 'Office Assistant I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-06-28', 'Sales Associate', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-09-06', 'VP Product Management', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-07-21', 'Media Manager II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-05-24', 'Senior Quality Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-05-09', 'Computer Systems Analyst II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-05-26', 'Research Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-09-25', 'Help Desk Technician', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-05-23', 'Account Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-11-23', 'Health Coach II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-09-08', 'Occupational Therapist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-03-30', 'Software Test Engineer IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-03-10', 'Marketing Assistant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-07-10', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-03-16', 'Senior Developer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-02-20', 'Senior Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-14', 'Junior Executive', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-09-02', 'Accounting Assistant I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-02-06', 'Web Designer III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-06-16', 'Administrative Assistant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-05-23', 'GIS Technical Architect', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-12-24', 'Senior Sales Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-21', 'Senior Quality Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-10-26', 'Human Resources Assistant III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-10-07', 'Biostatistician III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-02', 'Compensation Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-12-21', 'Electrical Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-10-01', 'Budget/Accounting Analyst I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-11-12', 'Chemical Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-05-29', 'Food Chemist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-11-27', 'Web Developer I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-10-01', 'Chief Design Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-10-30', 'Account Representative III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-04-08', 'Senior Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-06-26', 'Help Desk Operator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-10-11', 'VP Accounting', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-08-19', 'Assistant Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-06', 'Assistant Media Planner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-10-23', 'Developer IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-02-02', 'VP Product Management', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-25', 'Senior Cost Accountant', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-05-20', 'Assistant Media Planner', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-09-26', 'Accounting Assistant IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-12-05', 'Electrical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-10-15', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-09-12', 'Systems Administrator II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-08-08', 'Junior Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-12-31', 'Structural Analysis Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-08-05', 'Staff Scientist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-08-24', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-05-16', 'Business Systems Development Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-03-23', 'Automation Specialist II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-12-12', 'Assistant Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-06-13', 'Programmer Analyst II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-12-26', 'Web Developer III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-07-02', 'Web Developer III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-07-11', 'Data Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-09-06', 'Programmer I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-09-11', 'Account Executive', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-11-25', 'Nuclear Power Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-10-19', 'Web Developer II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-06-11', 'Analyst Programmer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-09-14', 'Environmental Specialist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-05-16', 'Pharmacist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-09-12', 'Physical Therapy Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-09-21', 'GIS Technical Architect', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-09-02', 'Mechanical Systems Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-06-24', 'Pharmacist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-02-12', 'Internal Auditor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-07-24', 'Nurse Practicioner', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-03-06', 'Analog Circuit Design manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-06-27', 'Librarian', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-07-17', 'Registered Nurse', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-08-23', 'Automation Specialist IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-02-11', 'Analyst Programmer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-05-17', 'Biostatistician III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-02-21', 'Human Resources Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-01-14', 'Environmental Tech', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-09-14', 'Analyst Programmer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-04-22', 'Safety Technician III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-09-19', 'Assistant Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-11-16', 'Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-05-12', 'Research Assistant II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-06-20', 'Engineer II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-01-22', 'Safety Technician III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-05-02', 'VP Sales', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-02-21', 'VP Quality Control', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-27', 'Account Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-03-06', 'Staff Scientist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-07-12', 'Human Resources Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-12-13', 'Mechanical Systems Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-04-27', 'Software Test Engineer I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-10-19', 'Account Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-03-30', 'Computer Systems Analyst I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-10-07', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-04-02', 'Safety Technician II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-07-08', 'Biostatistician I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-05-31', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-10-02', 'Geologist IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-11-17', 'VP Marketing', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-09-04', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-06-01', 'General Manager', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-10-16', 'Media Manager II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-10-28', 'Occupational Therapist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-11-03', 'Software Engineer IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-03', 'Accounting Assistant I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-03-22', 'Research Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-04-10', 'Civil Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-01-09', 'Research Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-02-01', 'Executive Secretary', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-08-16', 'Junior Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-12-13', 'Internal Auditor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-01-17', 'Physical Therapy Assistant', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-02-11', 'Systems Administrator III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-12-05', 'VP Sales', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-03-26', 'Account Executive', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-07-19', 'Assistant Media Planner', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-02-08', 'Geologist III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-11-01', 'Database Administrator I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-07-28', 'Sales Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-02-19', 'Associate Professor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-03-03', 'Clinical Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-06-03', 'Associate Professor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-10-23', 'Junior Executive', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-03-10', 'Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-01-05', 'Chemical Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-09-19', 'Assistant Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-12-19', 'Social Worker', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-04-05', 'Internal Auditor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-09-17', 'Research Assistant IV', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-10-01', 'GIS Technical Architect', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-01-21', 'Pharmacist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-12-17', 'Senior Sales Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-11-01', 'Accounting Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-07-24', 'Budget/Accounting Analyst III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-02-23', 'Financial Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-01-26', 'Research Assistant IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-06-01', 'Information Systems Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1997-01-10', 'Structural Analysis Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-03-28', 'Account Representative I', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-11-19', 'Automation Specialist I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-01-16', 'Sales Associate', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1970-11-18', 'Account Coordinator', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-02-19', 'Senior Developer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-04-30', 'Graphic Designer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-02-11', 'Human Resources Assistant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-07-30', 'Analyst Programmer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-23', 'Biostatistician III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-09-18', 'Social Worker', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-09-24', 'Structural Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-04-15', 'Occupational Therapist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-10-09', 'Engineer I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-11-11', 'Financial Analyst', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-04-23', 'Pharmacist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-06-15', 'Safety Technician III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-11-28', 'Assistant Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-03-10', 'Research Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-12-10', 'Assistant Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-10-10', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-07-24', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-03-06', 'Assistant Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-09-07', 'Civil Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-05-25', 'Recruiting Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-06-04', 'Software Engineer II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-06-19', 'Media Manager II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-02-02', 'Payment Adjustment Coordinator', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-09-22', 'Accountant II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-05-31', 'Analyst Programmer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-10-27', 'Project Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-04-24', 'Senior Developer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-06-29', 'Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-05-20', 'Administrative Assistant II', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-06-07', 'Nurse Practicioner', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-09-15', 'Financial Advisor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-12-07', 'Developer II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-11-17', 'Administrative Assistant I', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-06-28', 'Account Executive', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-02-26', 'Human Resources Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1991-06-30', 'Staff Scientist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-04-13', 'VP Quality Control', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-06-18', 'Community Outreach Specialist', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-01-24', 'Product Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-11-11', 'Editor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-12-11', 'Teacher', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-07-09', 'Research Assistant IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-12-21', 'Mechanical Systems Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-07-10', 'Design Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-04-14', 'Analog Circuit Design manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-07-26', 'Human Resources Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1972-10-02', 'Media Manager II', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-02-03', 'Senior Quality Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-09-07', 'Tax Accountant', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-10-16', 'Junior Executive', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-02-04', 'Research Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-05-23', 'Mechanical Systems Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-01-04', 'Electrical Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-05-04', 'Technical Writer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-02-19', 'General Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-11-06', 'Assistant Media Planner', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-03-01', 'Pharmacist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-01-17', 'Sales Representative', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-07-18', 'Research Associate', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-02-24', 'Systems Administrator IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-08-10', 'Quality Control Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-12-21', 'Structural Engineer', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-10-08', 'Budget/Accounting Analyst III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-07-22', 'Information Systems Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-09-02', 'Safety Technician IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1964-10-02', 'VP Accounting', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-04-17', 'Technical Writer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-03-20', 'Professor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1986-01-14', 'Structural Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-08-10', 'Assistant Manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-09-18', 'Assistant Media Planner', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-02-02', 'Internal Auditor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-01-31', 'Research Assistant IV', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-09-26', 'Accounting Assistant III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1960-09-29', 'Social Worker', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-08-23', 'Information Systems Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-09-06', 'Project Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1966-05-02', 'Data Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-10-05', 'Dental Hygienist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1977-10-09', 'Senior Editor', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1984-06-30', 'Speech Pathologist', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-09-07', 'Mechanical Systems Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-06-04', 'Operator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-08-01', 'Actuary', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-03-22', 'Compensation Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-06-24', 'Physical Therapy Assistant', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-08-22', 'Help Desk Technician', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-12-11', 'Web Developer IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-03-04', 'Desktop Support Technician', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-02-27', 'Staff Scientist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-01-04', 'Senior Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-11-12', 'Clinical Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-09-21', 'Accounting Assistant III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1981-06-21', 'Administrative Officer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-08-25', 'Research Nurse', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-11-10', 'Nurse', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-08-19', 'Geological Engineer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-02-22', 'Financial Advisor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1974-04-26', 'Analog Circuit Design manager', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-01-23', 'Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-07-29', 'Analog Circuit Design manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-06-23', 'VP Accounting', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1961-09-22', 'Nurse Practicioner', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1979-06-07', 'Programmer Analyst I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1975-02-23', 'Recruiting Manager', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1999-08-04', 'Associate Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1987-01-23', 'Biostatistician III', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-12-12', 'Marketing Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-06-18', 'Associate Professor', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-10-06', 'Senior Financial Analyst', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-03-15', 'Environmental Specialist', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1993-08-29', 'Software Test Engineer I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1962-08-03', 'Programmer Analyst IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-12-15', 'Help Desk Operator', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1983-09-20', 'Biostatistician II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1988-11-02', 'Geologist III', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-05-28', 'Staff Scientist', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1971-09-01', 'Web Designer II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-05-12', 'Human Resources Manager', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1963-09-17', 'Biostatistician III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2001-09-28', 'Civil Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-01-28', 'Business Systems Development Analyst', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-04-11', 'Systems Administrator I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1995-11-04', 'Statistician II', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1969-12-26', 'Account Representative II', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1998-04-28', 'Office Assistant III', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-12-24', 'Software Engineer IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1992-06-10', 'Electrical Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1994-02-09', 'Desktop Support Technician', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-04-08', 'Director of Sales', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1978-07-02', 'Graphic Designer', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1973-03-21', 'Web Designer I', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1989-02-01', 'Senior Editor', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1980-08-29', 'Budget/Accounting Analyst III', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-03-31', 'Senior Editor', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2000-02-04', 'Administrative Assistant I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1985-10-10', 'Automation Specialist I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1990-01-13', 'Budget/Accounting Analyst I', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1965-08-25', 'Senior Quality Engineer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '2002-09-12', 'Mechanical Systems Engineer', 'M', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1996-08-17', 'Graphic Designer', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1968-06-22', 'Database Administrator IV', 'S', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1982-04-01', 'Account Representative IV', 'S', 'F');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1967-10-18', 'Payment Adjustment Coordinator', 'M', 'M');
insert into Users.user_profiles (uspro_national_id, uspro_birth_date,  uspro_job_title, uspro_marital_status, uspro_gender) values ('Bolivia', '1976-06-03', 'Payment Adjustment Coordinator', 'M', 'M');
go



--Modulo Recursos humanos   


--  3.1 departamentos     14 
INSERT INTO HR.department (dept_name, dept_modified_date) VALUES 
('Departamento de Recepcion','01-01-2011'),
('Departamento de Direccion','01-01-2011'),
('Departamento de Limpieza','01-01-2011'),
('Departamento de Restauracion','01-01-2011'),
('Departamento de Cocina','01-01-2011'),
('Departamento de Mantenimiento','01-01-2015'),
('Departamento de Contabilidad y Finanzas','01-01-2015'),
('Departamento de Seguridad','01-01-2011'),
('Departamento de Ventas y Reservas','01-01-2011'),
('Departamento de Marketing','01-01-2015'),
('Departamento de Compras','01-01-2011'),
('Departamento de TI','01-01-2015'),
('Departamento de fitness','01-01-2015'),
('Departamento de Spa','01-01-2015')
go 

--3.2  rol de trabajo     15
INSERT INTO HR.job_role (joro_name, joro_modified_date) VALUES 
('Recepcionista','01-01-2011'),
('Botones','01-01-2011'),
('Ama de llaves','01-01-2011'),
('Camarero','01-01-2011'),
('Cocinero','01-01-2011'),
('Auxiliar de cocina','01-01-2011'),
('Friega platos','01-01-2011'),
('Personal de seguridad','01-01-2011'),
('Animador','01-06-2015'),
('Socorrista','01-01-2015'),
('Masajista','01-01-2015'),
('Hotel manager','01-01-2011'),
('Personal de mantenimiento','01-01-2012'),
('Conserje','01-01-2015'),
('Agente de reservas','01-01-2015'),
('Entrenador','01-01-2015')
go 


 --3.3 turno               16
INSERT INTO HR.shift (shift_name, shift_start_time, shift_end_time) VALUES 
('Turno mañana', '06:00', '14:00'),
('Turno tarde', '14:00', '22:00'),
('Turno noche', '22:00', '06:00');

go

-- 3.4  empleados              17
INSERT INTO HR.employee(emp_national_id,emp_birth_date,emp_marital_status,emp_gender,emp_hire_date,emp_salaried_flag,
emp_vacation_hours, emp_sickleave_hourse, emp_emp_id,emp_photo,emp_modified_date,emp_joro_id) VALUES 
(6267374,'17/05/1985','V','M','09/12/2019',1,360,24,NULL,'https://img.freepik.com/foto-gratis/hombre-mayor-pulgar-arriba_1187-829.jpg?w=360&t=st=1694789362~exp=1694789962~hmac=0b67409247ed7e1100822de93d85bbcc22ea5bbbc557080d00487277319a87aa',GETDATE(),7),
(4279017,'12/10/2006','C','M','13/12/2014',1,360,72,2,'https://img.freepik.com/foto-gratis/hombre-caucasico-mediana-edad-ropa-informal-sonriendo-cara-feliz-mirando-apuntando-lado-pulgar-arriba_839833-29987.jpg?w=740&t=st=1694789673~exp=1694790273~hmac=13bf410460cdc383d57ffa6c4a6864469a5b60d2942f432355b757400ad89733',GETDATE(),3),
(3919971,'22/03/1997','V','M','05/12/2016',1,360,48,NULL,'https://img.freepik.com/foto-gratis/vista-frontal-hombre-sonriente-espacio-copia_23-2148404240.jpg?w=740&t=st=1694789379~exp=1694789979~hmac=78d40eb9ff5ea9b7433e94ba53d9be38a14d74899f02b5bdcee79c30b19b1c5b',GETDATE(),14),
(3811690,'24/02/1986','S','M','09/11/2011',0,720,48,NULL,'https://img.freepik.com/fotos-premium/retrato-anciano-feliz-camisa-azul-anteojos-hoja-blanca-papel-vista-recortada_561613-17475.jpg?w=740',GETDATE(),8),
(5947926,'04/06/1980','S','M','27/02/2018',1,360,48,NULL,'https://img.freepik.com/fotos-premium/joven-brasileno-caucasico-aislado-fondo-blanco-mirando-lado-sonriendo_1368-412051.jpg?w=740',GETDATE(),14),
(6155840,'02/06/1999','C','M','13/03/2014',1,360,72,NULL,'https://img.freepik.com/foto-gratis/hombre-brazos-cruzados_1368-9618.jpg?w=360&t=st=1694789633~exp=1694790233~hmac=883302d4e8b8146ba84e648af785aa6265735088cb9dc4fac80f5520cf6953b6',GETDATE(),1),
(8209922,'04/02/2001','S','M','12/12/2013',0,360,24,1,'https://img.freepik.com/foto-gratis/alegre-joven-deportista-posando-mostrando-pulgares-arriba-gesto_171337-8194.jpg?w=740&t=st=1694789483~exp=1694790083~hmac=de8c0119a15ef456d2289648156daa117850e6f70e4b0283575287cfd94ee6e0',GETDATE(),15),
(4014027,'01/08/1985','D','M','24/12/2013',0,360,NULL,2,'https://img.freepik.com/foto-gratis/retrato-hombre-tatuajes-cuerpo_23-2150774627.jpg?w=360&t=st=1694789648~exp=1694790248~hmac=857c6c7b44c9a9884e74187fe2f9790220162ab86c76a0d55684f06a8f7c7d79',GETDATE(),3),
(7682404,'18/04/2001','V','M','14/01/2010',1,720,72,NULL,'https://img.freepik.com/foto-gratis/hombre-inteligente-informal-dando-pulgares-arriba_53876-26364.jpg?w=740&t=st=1694789496~exp=1694790096~hmac=bcb3d96a386265544520ab158accabe0815456d8845f888111e7f84fef2252d2',GETDATE(),1),
(6216554,'22/10/2001','C','M','08/03/2015',0,480,24,NULL,'https://img.freepik.com/fotos-premium/apuesto-joven-camisa-rosa-sobre-pared-azul-aislado-riendo_1368-55070.jpg?w=740',GETDATE(),13),
(7388987,'24/04/1989','S','M','01/12/2010',1,720,NULL,2,'https://img.freepik.com/foto-gratis/imagen-apuesto-joven-confiado-camisa-blanca-sosteniendo-tableta-digital-generica-sonriendo-ampliamente-disfrutando-juegos-usando-aplicacion-linea-tecnologia-entretenimiento-juegos_343059-4594.jpg?w=740&t=st=1694789579~exp=1694790179~hmac=7840e33079c259e94daad5399a024b2d4a66c60312933615561eff76be1b27a7',GETDATE(),3),
(4582640,'21/08/2002','V','M','22/04/2017',0,360,48,2,'https://img.freepik.com/foto-gratis/tipo-decepcionado-que-parece-molesto-enfurrunado-frunciendo-ceno-pie-disgustado-contra-fondo-amarillo_1258-170846.jpg?w=996&t=st=1694789510~exp=1694790110~hmac=ef6f9bd480bee2e86556422dfb82b19fd7b761e79c46c1caeebf370c74af6a1b',GETDATE(),14),
(3728104,'24/03/1989','S','M','16/01/2015',0,360,72,NULL,'https://img.freepik.com/foto-gratis/retrato-joven-sonriente-gafas_171337-4842.jpg?w=740&t=st=1694789713~exp=1694790313~hmac=4dd593d42d7b4e7aee337d7627bc483f963a7260402a5fd9b92cdd72212d30c2',GETDATE(),7),
(5015938,'09/07/2000','D','M','07/03/2010',1,720,24,NULL,'https://img.freepik.com/foto-gratis/hombre-pulgar-arriba-sobre-fondo-blanco_1368-4483.jpg?w=740&t=st=1694789600~exp=1694790200~hmac=13b3776006d2aaf73e164353446e495c7d8d7f20a6eb43236e494631b2cdb6d4',GETDATE(),3),
(7293712,'14/05/1995','C','M','14/09/2016',1,360,24,NULL,'https://img.freepik.com/foto-gratis/hombre-senior-camisa-purpura-mirando-camara-feliz-positivo-haciendo-bien-firmar-sonriendo-alegremente-pie-sobre-fondo-color-rosa_141793-116645.jpg?w=740&t=st=1694789541~exp=1694790141~hmac=355736e5b2898dc1e1a74c888e8b97fa3e90d3c8a29006193328d7782a04c02c',GETDATE(),8),
(7681369,'23/05/1987','D','M','22/07/2022',1,360,48,NULL,'https://img.freepik.com/foto-gratis/hombre-camisa-azul-pulgar-arriba_1368-4929.jpg?w=360&t=st=1694789730~exp=1694790330~hmac=b5a4f4652612d045ad3bf396708d09704143133e4316fe9bca6e1681a9725cd3',GETDATE(),3),
(6960690,'04/12/2001','S','M','02/03/2023',1,NULL,72,3,'https://img.freepik.com/foto-gratis/vista-frontal-hombres-jovenes-camiseta-color-rojo-oscuro-pie-sonriendo-sobre-fondo-blanco_140725-121650.jpg?w=740&t=st=1694789660~exp=1694790260~hmac=230ac4a3307dcea7deaf560d33a9e9e6b4442e1482abca567078421ad04c9100',GETDATE(),2),
(4027951,'09/09/1980','D','M','19/08/2017',1,360,NULL,NULL,'https://img.freepik.com/foto-gratis/hombre-moreno-positiva-brazos-cruzados_1187-5797.jpg?w=740&t=st=1694789620~exp=1694790220~hmac=07c70b190e8f80281c04d25aeff484350eaebff6936524e2f14c5b2dcbf0477b',GETDATE(),3),
(6782231,'25/06/1984','D','M','10/09/2021',1,360,48,NULL,'https://img.freepik.com/foto-gratis/retrato-primer-plano-joven-afroamericano-profesional-exitoso-sudadera-capucha-roja-pecho-brazos-cruzados_176420-33867.jpg?w=740&t=st=1694789854~exp=1694790454~hmac=c95ede8e77d73e4ee09cddeac8aa97191451b43171a4ddbc28dff57c20ca234c',GETDATE(),3),
(4361879,'04/02/1980','D','M','13/08/2016',0,360,NULL,NULL,'https://img.freepik.com/fotos-premium/retrato-guapo-joven-africano-hombre-llevando-gafas_219728-5590.jpg?w=740',GETDATE(),1),
(5181935,'19/04/1980','S','M','05/07/2020',1,360,72,7,'https://img.freepik.com/foto-gratis/hombre-hispano-barba-sueter-casual-invierno-alegre-sonrisa-cara-apuntando-mano-dedo-lado-expresion-feliz-natural_839833-9834.jpg?w=740&t=st=1694789872~exp=1694790472~hmac=20f499609dfa094ab8449e4d29bac6e437368e8c462af4f0e087bd71832034af',GETDATE(),6),
(4560481,'04/04/2006','C','M','26/03/2012',0,720,24,NULL,'https://img.freepik.com/foto-gratis/retrato-adulto-casual_144627-27312.jpg?w=360&t=st=1694789761~exp=1694790361~hmac=b1e1057cdad10cb47204c9079d5639a15329e23fbfd769faa758e1735011e4c4',GETDATE(),13),
(6465852,'14/10/1980','C','M','23/02/2010',1,720,NULL,NULL,'https://img.freepik.com/foto-gratis/retrato-hombre-negocios-exitoso-ceo-trabajador-oficina-feliz-sonriendo-complacido-pie-contra-fondo-blanco-camisa-cuello-azul_176420-45223.jpg?w=740&t=st=1694789839~exp=1694790439~hmac=b005bb229b2667f76d80a13ffb30ef5ec35769e08538adbf862f5cd8b81766bb',GETDATE(),3),
(7346447,'07/04/1989','C','M','04/06/2023',1,NULL,24,NULL,'https://img.freepik.com/foto-gratis/apuesto-joven-empresario-brazos-cruzados-sonriendo-confiado_176420-21730.jpg?w=740&t=st=1694789786~exp=1694790386~hmac=34b1e4ee728f9b36f75eb5b0c596e6b28ffb8bc96d079adee5ecb550f0675d63',GETDATE(),4),
(8102263,'05/10/1982','V','M','26/09/2021',0,360,72,NULL,'https://img.freepik.com/fotos-premium/hombre-irresistible-encantador-joven-mirando-camara-sonriendo-mientras-pie-contra-fondo-gris_425904-6477.jpg?w=740',GETDATE(),7),
(6329301,'12/09/1992','C','M','01/07/2017',1,360,NULL,NULL,'https://img.freepik.com/foto-gratis/primer-plano-hombre-sonriendo-mercado_23-2150771087.jpg?w=360&t=st=1694789896~exp=1694790496~hmac=1cd9c52b71dda0e929ca3914aeb871ccbf87630a93494cca79ca871d5d241591',GETDATE(),3),
(6987779,'14/03/1985','D','M','29/05/2016',1,360,48,10,'https://img.freepik.com/foto-gratis/primer-plano-hombre-mediana-edad-decepcionado-sueter-gris-frunciendo-ceno-molesto-mirando-izquierda-espacio-copia_1258-180430.jpg?w=900&t=st=1694789817~exp=1694790417~hmac=c7fd7b6ae7d599659982cc3c91b5838e44f8a7edf966f407353f5a7a0249f4b8',GETDATE(),8),
(5577795,'25/12/1998','S','M','14/09/2020',1,360,72,NULL,'https://img.freepik.com/fotos-premium/retrato-hombre-maduro-encantador-que-siente-verdaderas-emociones-contenido-camisa-beige-aislada_206895-2235.jpg?w=740',GETDATE(),7),
(3933329,'02/02/2004','V','M','10/12/2010',1,720,24,NULL,'https://img.freepik.com/fotos-premium/joven-latino-aislado-fondo-amarillo-apuntando-lado-presentar-producto_1368-284988.jpg?w=740',GETDATE(),9),
(7931915,'03/09/1991','V','M','01/07/2022',0,360,48,NULL,'https://img.freepik.com/fotos-premium/hombre-caucasico-joven-que-levanta-ambos-pulgares-arriba-sonriente-confiado_1187-84646.jpg?w=826',GETDATE(),1),
(4625749,'05/04/2003','S','M','27/03/2010',1,720,24,NULL,'https://img.freepik.com/foto-gratis/trabajador-cumplio-tarea-sonrio-lado_1150-52084.jpg?w=740&t=st=1694789917~exp=1694790517~hmac=c7d55911eb1f8c3372cfc6d1f6ea6133158b3aa9fba980ef2d0ab579f40e3d25',GETDATE(),3),
(3720489,'02/01/1992','C','M','24/03/2010',0,720,NULL,3,'https://img.freepik.com/foto-gratis/joven-constructor-casco-blanco-chaleco-amarillo-sosteniendo-portapapeles-sonrisa-pie-azul-aislado_141793-8548.jpg?w=360&t=st=1694789967~exp=1694790567~hmac=455f2a83d08c2b968072df2ce1c111b10d001492dc81d85b249f97fb5139597c',GETDATE(),2),
(5549835,'15/07/1987','S','M','27/02/2019',0,360,48,NULL,'https://images.unsplash.com/photo-1530268729831-4b0b9e170218?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',GETDATE(),13),
(8227767,'04/03/1989','S','M','01/02/2019',0,360,72,NULL,'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1374&q=80',GETDATE(),12),
(4607872,'04/02/2007','V','M','27/07/2022',1,360,24,NULL,'https://img.freepik.com/foto-gratis/retrato-hombre-que-usa-tableta-digital_1170-1888.jpg?w=360&t=st=1694789984~exp=1694790584~hmac=0a9f10d4d9db3a70fc476384a3d59e570fb49c0ac768b24fbf86a9fa895258e2',GETDATE(),2),
(4129325,'03/11/1998','D','M','09/07/2022',1,360,24,NULL,'https://img.freepik.com/foto-gratis/hombre-guapo-joven-ropa-informal-verano-que-invita-entrar-sonriendo-natural-mano-abierta_839833-14649.jpg?w=740&t=st=1694790008~exp=1694790608~hmac=fabfb9dde511f97972bc45a9c6f44ea5711aa1d9df2c512b1ea7a618148d60de',GETDATE(),3),
(5239771,'10/10/1994','C','M','08/05/2017',1,360,NULL,3,'https://plus.unsplash.com/premium_photo-1689530775582-83b8abdb5020?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',GETDATE(),11),
(6191716,'08/02/2005','V','M','22/02/2015',1,360,24,3,'https://img.freepik.com/foto-gratis/primer-plano-joven-exitoso-sonriendo-camara-pie-traje-casual-contra-fondo-azul_1258-66609.jpg?w=740&t=st=1694790021~exp=1694790621~hmac=253f9123f80ad5f8cdcf2b36f9d237ef547581a680679650ebc77bd01d949a8d',GETDATE(),11),
(6497742,'09/09/1993','C','M','06/07/2020',0,360,NULL,NULL,'https://images.unsplash.com/photo-1619194617062-5a61b9c6a049?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',GETDATE(),2),
(4452294,'24/01/1997','C','M','05/07/2019',0,360,24,NULL,'https://img.freepik.com/foto-gratis/hombre-guapo-joven-camisa-casual-gafas-pie-sobre-signo-exito-fondo-rosa_839833-18277.jpg?w=740&t=st=1694790035~exp=1694790635~hmac=6da09e725f09ad35f1bd81db0cf9d1c02587a3e0fbc7df48a790d5492643c506',GETDATE(),10),
(6824028,'14/05/2001','V','M','22/10/2010',1,720,NULL,6,'https://plus.unsplash.com/premium_photo-1688891564708-9b2247085923?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1374&q=80',GETDATE(),5),
(7100448,'05/03/1997','D','M','12/06/2018',0,360,72,NULL,'https://img.freepik.com/foto-gratis/hombre-sonriente-tiro-medio-espacio-copia_23-2148686054.jpg?w=826&t=st=1694790048~exp=1694790648~hmac=6632b37b121d1ce60e8b2d327548062f09b15d38e1c7a1ed55bef05387eb2b10',GETDATE(),2),
(5869779,'16/12/1995','C','M','17/04/2013',1,720,24,2,'https://img.freepik.com/foto-gratis/retrato-cuerpo-entero-hombre-feliz-confiado_171337-4818.jpg?w=360&t=st=1694790061~exp=1694790661~hmac=1bb1e7b298ddadb55efcce905ae88a6d8c635a52bc71a3248a38a4bf0613d049',GETDATE(),4),
(6559043,'03/01/1998','S','M','16/07/2023',1,NULL,48,NULL,'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1374&q=80',GETDATE(),10),
(3781506,'05/02/2002','C','M','03/12/2014',0,480,72,NULL,'https://img.freepik.com/foto-gratis/joven-brunet-camiseta-blanca_273609-21717.jpg?w=740&t=st=1694789161~exp=1694789761~hmac=d630b27474cd8fb999cbde55624eb751c8ea3e7097cbf7e8104636aa691d37be',GETDATE(),3),
(7873095,'04/12/1987','D','M','08/01/2016',0,360,NULL,NULL,'https://images.unsplash.com/photo-1492447216082-4726bf04d1d1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80',GETDATE(),2),
(5623209,'10/02/1993','V','M','31/01/2016',1,360,24,NULL,'https://img.freepik.com/fotos-premium/hombre-guapo-joven-barba-sobre-aislado-manteniendo-brazos-cruzados-posicion-frontal_1368-132662.jpg?w=740',GETDATE(),11),
(5828710,'14/06/1980','V','M','22/10/2020',0,360,NULL,6,'https://img.freepik.com/foto-gratis/feliz-sonriente-guapo-contra-fondo-azul_93675-135164.jpg?w=740&t=st=1694789147~exp=1694789747~hmac=388fd20ca2e2668cb482f126ea75b475d9ddcebb8c7b1ed920f3ad320dbbf401',GETDATE(),5),
(7626898,'25/07/1990','S','M','07/06/2018',0,360,48,7,'https://img.freepik.com/foto-gratis/feliz-joven_1098-20869.jpg?w=740&t=st=1694789126~exp=1694789726~hmac=a57f83f2470044b2a355a2bf84b9eed8d6c62a9471a2acf91c5646ea9fa995b9',GETDATE(),6),
(7866821,'21/11/2005','C','M','19/07/2017',1,360,24,NULL,'https://img.freepik.com/foto-gratis/concepto-premio-loteria-ganar-hombre-joven-feliz-emocionado-grita-si-exito-lograr-meta-bomba-puno_176420-33769.jpg?w=740&t=st=1694790090~exp=1694790690~hmac=54d964ad64b665dfeacc7b8cabbeb25cb3afabc10d84f9762ac5709e72c9352f',GETDATE(),2),
(7312700,'05/03/1982','V','M','23/05/2023',0,NULL,72,NULL,'https://img.freepik.com/foto-gratis/retrato-hombre-sonriendo-parque_23-2150771023.jpg?w=826&t=st=1694790075~exp=1694790675~hmac=6f10718cd3c065669dd7d6eb97885a4e410e9aefdfdd156402b3c4d3a52f1793',GETDATE(),7),
(3724982,'21/03/1986','S','M','20/05/2018',1,360,NULL,NULL,'https://img.freepik.com/fotos-premium/felicidad-concepto-gente-hombre-sonriente-camiseta-blanca-brazos-cruzados_380164-89171.jpg?w=360',GETDATE(),8),
(7403425,'02/01/2004','V','M','19/11/2010',1,720,72,3,'https://img.freepik.com/foto-gratis/hombre-sonriente-estilo-joven-oficina-trabajo-conjunto-autonomo-inicio-sosteniendo-usando-tableta_285396-9048.jpg?w=740&t=st=1694789315~exp=1694789915~hmac=366ce28f4930c72a36e282c97bf682fdd5966ce54bea4d9c0b92f7c1b7ec18eb',GETDATE(),2),
(4379236,'05/07/1983','S','M','03/09/2019',1,360,24,2,'https://img.freepik.com/foto-gratis/hombre-moreno-moda-posando_273609-22453.jpg?w=740&t=st=1694790112~exp=1694790712~hmac=117cd1586b6f555c8e7aa648a55d5dfe08423d27a221641e6a9d03a2cd760369',GETDATE(),4),
(7378339,'11/11/1991','C','M','07/08/2012',0,720,48,NULL,'https://img.freepik.com/foto-gratis/retrato-joven-atractivo-vestido-informalmente-usando-tableta-sonriendo-fondo-blanco_662251-2948.jpg?w=740&t=st=1694789192~exp=1694789792~hmac=d510864284a4602b532c5f3ad03cf048849de4a77416251788c7a20c0784bdeb',GETDATE(),2),
(5174699,'21/10/1998','S','M','13/12/2021',1,360,48,NULL,'https://img.freepik.com/foto-gratis/hombre-llevando-rojo-polo-camisa_1368-794.jpg?w=360&t=st=1694789350~exp=1694789950~hmac=5ddc90362d926bc6df1f88c585e27826cc42c5b60d62d3b026659388d47acbfc',GETDATE(),11),
(3759802,'01/11/1991','C','M','28/01/2016',1,360,NULL,7,'https://img.freepik.com/foto-gratis/joven-hombre-apuesto-camiseta-informal-sonriendo-alegremente-presentando-senalando-palma-mano-mirando-camara_839833-19973.jpg?w=740&t=st=1694789299~exp=1694789899~hmac=a8bdce5cadcdf23b231847c7a60b21d726bb45dc6a1c0d1a543d9e3c208cb98f',GETDATE(),6),
(4405763,'05/12/1998','S','M','31/10/2017',0,360,48,NULL,'https://img.freepik.com/foto-gratis/apuesto-joven-brazos-cruzados-sobre-fondo-blanco_23-2148222620.jpg?w=740&t=st=1694789266~exp=1694789866~hmac=a3732d61036e5f28572e64fec76ba8f9826fdc31dfa042c2e7f2fa2ec26f10d0',GETDATE(),2),
(6490867,'09/10/1984','V','M','26/07/2021',0,360,NULL,6,'https://img.freepik.com/foto-gratis/retrato-joven-feliz-camisa-blanca_171337-17462.jpg?w=740&t=st=1694789329~exp=1694789929~hmac=3cb03c4598759f271b8a24d47d3944b8adbc90d450c4922b5e8e9d5f16477efe',GETDATE(),5),
(3837032,'03/12/2005','D','M','16/01/2020',0,360,48,NULL,'https://img.freepik.com/fotos-premium/hombre-casual-feliz-telefono-inteligente-pulgar-arriba-sobre-gris_1258-14279.jpg?w=740',GETDATE(),11),
(7701356,'21/11/1982','D','M','10/09/2011',0,720,48,NULL,'https://img.freepik.com/foto-gratis/retrato-hombre-foding-sus-manos_171337-15873.jpg?w=740&t=st=1694789285~exp=1694789885~hmac=e972f01e3b844b7714941c79794b6282565d66dae99a406a15123a66a2b943bd',GETDATE(),4),
(6655695,'17/10/1983','S','M','01/09/2023',1,NULL,72,NULL,'https://img.freepik.com/fotos-premium/hombre-sobre-fondo-aislado_1368-333502.jpg?w=740',GETDATE(),2),
(5186552,'16/04/2001','S','M','12/05/2017',1,480,48,7,'https://img.freepik.com/foto-gratis/retrato-hombre-atractivo-satisfecho-contento-feliz-camisa-moda-mezclilla-que-muestra-su-dedo-indice-esquina-superior-derecha_295783-1217.jpg?w=740&t=st=1694790158~exp=1694790758~hmac=e241dc02fc36227911f68bb2d0f33c29c335bff52f160c2157fb5fd74c7bed56',GETDATE(),6),
(7433434,'09/10/1983','S','M','14/02/2011',0,720,24,2,'https://img.freepik.com/foto-gratis/joven-arabe-vestido-ropa-informal-que-aparece-senala-dedos-numero-cuatro-mientras-sonrie-confiado-feliz_839833-25521.jpg?w=740&t=st=1694790174~exp=1694790774~hmac=6b5582cc6adf08f370da79937167940878a1646d46d0b410ca41f6f26d2a44f1',GETDATE(),4);
go


 



--MODULO PAYMENT



 ---5.1 entidad    18
DECLARE @counter INT = 1;
WHILE @counter <= 10  
BEGIN
    INSERT INTO Payment.entity DEFAULT VALUES;
    SET @counter = @counter + 1;
END;


-- 5.2 Inserciones en la tabla Payment.bank   19
INSERT INTO Payment.bank (bank_entity_id, bank_code, bank_name)
VALUES (1, 'BANCO1', 'Banco Ganadero'),
      (2, 'BANCO2', 'Banco Mercantil Santa Cruz'),
     (3, 'BANCO3', 'Banco Nacional de Bolivia');
go




 --Modulo Purchasing
--4.1 proveedor      20
  INSERT INTO purchasing.vendor (vendor_entity_id, vendor_name, vendor_active, vendor_priority, vendor_weburl)
VALUES

(4, 'Proveedor A', 1, 0, 'http://www.proveedor-a.com'),
(5, 'Proveedor B', 1, 1, 'http://www.proveedor-b.com'),
(6, 'Proveedor C', 0, 0, 'http://www.proveedor-c.com'),
(7, 'Proveedor D', 1, 0, 'http://www.proveedor-d.com'),
(8, 'Proveedor E', 1, 1, 'http://www.proveedor-e.com');

go


-- 4.2 Registros de ejemplo para la tabla purchasing.stocks  21
-- Insertar productos en la tabla purchasing.stocks
INSERT INTO purchasing.stocks (stock_name, stock_description, stock_quantity, stock_price, stock_modified_date)
VALUES
    ('Pastel de Chocolate', 'Delicioso pastel de chocolate', 50, 5.99, GETDATE()),
    ('Helado de Vainilla', 'Helado cremoso de vainilla', 100, 3.49, GETDATE()),
    ('Galletas de Chocolate', 'Galletas crujientes de chocolate', 200, 2.99, GETDATE()),
    ('Refresco de Cola', 'Bebida refrescante de cola', 150, 1.99, GETDATE()),
    ('Jugo de Naranja', 'Jugo natural de naranja', 80, 2.49, GETDATE()),
    ('Chips de Papas', 'Chips de papas salados', 300, 1.79, GETDATE()),
    ('Brownie de Nuez', 'Brownie con nueces', 40, 4.99, GETDATE()),
    ('Café', 'Taza de café recién preparado', 120, 1.29, GETDATE()),
    ('Gomitas de Frutas', 'Gomitas de frutas surtidas', 250, 1.49, GETDATE()),
    ('Batido de Fresa', 'Batido de fresa con crema', 70, 3.99, GETDATE()),
    ('Tarta de Manzana', 'Tarta de manzana recién horneada', 30, 6.49, GETDATE()),
    ('Agua Mineral', 'Botella de agua mineral', 200, 0.99, GETDATE()),
    ('Donas de Chocolate', 'Donas glaseadas con chocolate', 120, 1.79, GETDATE()),
    ('Cerveza', 'Botella de cerveza', 60, 4.49, GETDATE()),
    ('Palomitas de Maíz', 'Palomitas de maíz saladas', 180, 2.29, GETDATE()),
    ('Vino Tinto', 'Vino para la ocacion', 50, 3.49, GETDATE()),
    ('Limón Agrio', 'Limón agrio fresco', 40, 0.79, GETDATE()),
    ('Chocolate Caliente', 'Taza de chocolate caliente', 90, 2.99, GETDATE()),
    ('Almendras Tostadas', 'Almendras tostadas y saladas', 120, 3.99, GETDATE()),
    ('Tarta de Queso', 'Tarta de queso con frambuesas', 25, 7.99, GETDATE());


go
------22
INSERT INTO purchasing.stock_photo (spho_thumbnail_filename, spho_photo_filename, spho_primary, spho_url, spho_stock_id)
VALUES
    ('pastel_chocolate_thumb.jpg', 'pastel_chocolate_full.jpg', 1, 'https://ejemplo.com/pastel_chocolate', 1),
    ('helado_vainilla_thumb.jpg', 'helado_vainilla_full.jpg', 1, 'https://ejemplo.com/helado_vainilla', 2),
    ('galletas_chocolate_thumb.jpg', 'galletas_chocolate_full.jpg', 1, 'https://ejemplo.com/galletas_chocolate', 3),
    ('refresco_cola_thumb.jpg', 'refresco_cola_full.jpg', 1, 'https://ejemplo.com/refresco_cola', 4),
    ('jugo_naranja_thumb.jpg', 'jugo_naranja_full.jpg', 1, 'https://ejemplo.com/jugo_naranja', 5),
    ('chips_papas_thumb.jpg', 'chips_papas_full.jpg', 1, 'https://ejemplo.com/chips_papas', 6),
    ('brownie_nuez_thumb.jpg', 'brownie_nuez_full.jpg', 1, 'https://ejemplo.com/brownie_nuez', 7),
    ('cafe_thumb.jpg', 'cafe_full.jpg', 1, 'https://ejemplo.com/cafe', 8),
    ('gomitas_frutas_thumb.jpg', 'gomitas_frutas_full.jpg', 1, 'https://ejemplo.com/gomitas_frutas', 9),
    ('batido_fresa_thumb.jpg', 'batido_fresa_full.jpg', 1, 'https://ejemplo.com/batido_fresa', 10),
    ('tarta_manzana_thumb.jpg', 'tarta_manzana_full.jpg', 1, 'https://ejemplo.com/tarta_manzana', 11),
    ('agua_mineral_thumb.jpg', 'agua_mineral_full.jpg', 1, 'https://ejemplo.com/agua_mineral', 12),
    ('donas_chocolate_thumb.jpg', 'donas_chocolate_full.jpg', 1, 'https://ejemplo.com/donas_chocolate', 13),
    ('cerveza_thumb.jpg', 'cerveza_full.jpg', 1, 'https://ejemplo.com/cerveza', 14),
    ('palomitas_maiz_thumb.jpg', 'palomitas_maiz_full.jpg', 1, 'https://ejemplo.com/palomitas_maiz', 15),
    ('vino_tinto_thumb.jpg', 'vino_tinto_full.jpg', 1, 'https://ejemplo.com/vino_tinto', 16),
    ('limon_agrio_thumb.jpg', 'limon_agrio_full.jpg', 1, 'https://ejemplo.com/limon_agrio', 17),
    ('chocolate_caliente_thumb.jpg', 'chocolate_caliente_full.jpg', 1, 'https://ejemplo.com/chocolate_caliente', 18),
    ('almendras_tostadas_thumb.jpg', 'almendras_tostadas_full.jpg', 1, 'https://ejemplo.com/almendras_tostadas', 19),
    ('tarta_queso_thumb.jpg', 'tarta_queso_full.jpg', 1, 'https://ejemplo.com/tarta_queso', 20);






-- 4.3 Proveedor_producto   23
INSERT INTO purchasing.vendor_product (vepro_qty_stocked, vepro_qty_remaining, vepro_price, venpro_stock_id, vepro_vendor_id)
VALUES
(100, 100, 9.99, 1, 6),
(200, 200, 19.99, 2, 6),
(150, 150, 3.99, 3, 6),
(250, 250, 1.99, 4, 6),
(50, 50, 29.99, 5, 6),
(500, 500, 2.49, 6, 6),
(30, 30, 49.99, 7, 6),
(1000, 1000, 7.99, 8, 6),
(40, 40, 12.99, 9, 6),
(150, 150, 4.99, 10, 6),


(75, 75, 12.99, 1, 7),
(150, 150, 24.99, 2, 7),
(100, 100, 4.99, 3, 7),
(200, 200, 1.49, 4, 7),
(40, 40, 39.99, 5, 7),
(300, 300, 2.99, 6, 7),
(20, 20, 7.99, 7, 7),
(500, 500, 5.99, 8, 7),
(25, 25, 14.99, 9, 7),
(100, 100, 1.99, 10, 7),


(125, 125, 6.99, 1, 8),
(250, 250, 18.99, 2, 8),
(200, 200, 2.99, 3, 8),
(400, 400, 1.49, 4, 8),
(80, 80, 59.99, 5, 8),
(800, 800, 4.99, 6, 8),
(15, 15, 12.99, 7, 8),
(300, 300, 9.99, 8, 8),
(10, 10, 29.99, 9, 8),
(120, 120, 7.99, 10,8),


(90, 90, 3.49, 1, 4),
(180, 180, 6.99, 2, 4),
(150, 150, 1.99, 3, 4),
(300, 300, 0.99, 4, 4),
(60, 60, 24.99, 5, 4),
(600, 600, 1.49, 6, 4),
(10, 10, 39.99, 7, 4),
(400, 400, 3.99, 8, 4),
(20, 20, 9.99, 9, 4),
(90, 90, 2.49, 10, 4),


(110, 110, 4.99, 1, 5),
(220, 220, 9.99, 2, 5),
(180, 180, 1.99, 3, 5),
(360, 360, 0.99, 4, 5),
(70, 70, 29.99, 5, 5),
(700, 700, 1.49, 6, 5),
(12, 12, 49.99, 7, 5),
(450, 450, 4.99, 8, 5),
(30, 30, 11.99, 9, 5),
(110, 110, 2.99, 10, 5);




    UPDATE Users.users
    SET user_modified_date = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % (DATEDIFF(SECOND, '2022-09-01', '2023-09-19') + 1), '2022-09-01');
    go


---MOUDULO RESTO












  -- Crear un procedimiento almacenado para asignar aleatoriamente roles a usuarios
 ----TABLAS  NO MASTER 

CREATE or alter  PROCEDURE AssignRandomRolesToUsersEmpleados  --25
AS
BEGIN
    DECLARE @UserID INT ;DECLARE @RoleID INT ;DECLARE @MaxRecords INT 
    SET @MaxRecords =0 -- variable para n trabjadores
   
    DELETE FROM Users.user_roles 
    DECLARE UserCursor CURSOR FOR  -- Declarar un cursor para recorrer la tabla de usuarios
    SELECT user_id FROM Users.users
  	
	DECLARE @AvailableRoleIDs TABLE (role_id INT) -- Declarar una tabla temporal para almacenar los IDs de roles disponibles          
	INSERT INTO @AvailableRoleIDs (role_id)  -- Insertar todos los IDs de roles disponibles en la tabla temporal
    SELECT  role_id
    FROM Users.roles
	WHERE  Users.roles.role_name in ('camarero','Agente de reservas', 'masajista' , 'Recepcionista' , 
	 'Seguridad' , 'Mantenimiento' , 'Técnico')
    
    -- Recorrer la tabla de usuarios y asignar aleatoriamente roles
    OPEN UserCursor
    FETCH NEXT FROM UserCursor INTO @UserID
    
    WHILE @@FETCH_STATUS = 0 and @MaxRecords<300  --mientras hay filas para recorrer 
    BEGIN

	  
        -- Seleccionar un rol aleatorio de la tabla temporal
      
    SELECT TOP 1 @RoleID = role_id   
        FROM @AvailableRoleIDs   ORDER BY NEWID()    	   
        -- Insertar el par usuario-rol en la tabla user_roles
        INSERT INTO Users.user_roles (usro_user_id, usro_role_id)
        VALUES (@UserID, @RoleID)        
        FETCH NEXT FROM UserCursor INTO @UserID
		SET @MaxRecords= @MaxRecords+1
   
    END
    
    --Cerrar y liberar el cursor
    CLOSE UserCursor
    DEALLOCATE UserCursor
	
END
go 


  --26
CREATE or alter  PROCEDURE AssignRandomRolesToUsersClientes
AS
BEGIN
    DECLARE @UserID INT ;DECLARE @RoleID INT ;DECLARE @MaxRecords INT 
    SET @MaxRecords =0 -- variable para n trabjadores
   
   
    DECLARE UserCursor CURSOR FOR  -- Declarar un cursor para recorrer la tabla de usuarios
    SELECT user_id FROM Users.users
  	WHERE user_id NOT IN (SELECT DISTINCT usro_user_id FROM Users.user_roles);

	DECLARE @AvailableRolIDs TABLE (role_id INT) -- Declarar una tabla temporal para almacenar los IDs de roles disponibles          
	INSERT INTO @AvailableRolIDs (role_id)  -- Insertar todos los IDs de roles disponibles en la tabla temporal
    SELECT  role_id
    FROM Users.roles
	WHERE  Users.roles.role_name in ('Cliente Regular','Cliente VIP' , 'Huésped' ,'Visitante' , 'Turista','Invitado' ,'Cliente de Negocios','Cliente de Eventos',
	'Cliente de Vacaciones','Cliente de Lujo') 
    -- Recorrer la tabla de usuarios y asignar aleatoriamente roles
    OPEN UserCursor
    FETCH NEXT FROM UserCursor INTO @UserID
    
    WHILE @@FETCH_STATUS = 0 --mientras hay filas para recorrer 
    BEGIN	  
	     print @UserID
        -- Seleccionar un rol aleatorio de la tabla temporal
        begin try 
        SELECT TOP 1 @RoleID = role_id   
        FROM @AvailableRolIDs   ORDER BY NEWID()    	   
        -- Insertar el par usuario-rol en la tabla user_roles
        INSERT INTO Users.user_roles (usro_user_id, usro_role_id)
        VALUES (@UserID, @RoleID)        
        FETCH NEXT FROM UserCursor INTO @UserID  
     end try
	 begin catch
	   FETCH NEXT FROM UserCursor INTO @UserID 
	 end catch
	 
	  
	END
    
    --Cerrar y liberar el cursor
    CLOSE UserCursor
    DEALLOCATE UserCursor	
END
go 

---27
-- Crear un procedimiento almacenado para insertar registros de membresía
CREATE OR ALTER PROCEDURE InsertUserMemberships
AS
BEGIN
    
    DECLARE @UserID INT
    DECLARE @MembershipName NVARCHAR(35)
    DECLARE @PromoteDate DATETIME
    DECLARE @Points SMALLINT
    DECLARE @Type NVARCHAR(15)
	Truncate table Users.user_members
    -- Declarar un cursor para recorrer los usuarios
    DECLARE UserCursor CURSOR FOR
        SELECT users.user_id
        FROM Users.users ,Users.roles  ,Users.user_roles 
		where  Users.users.user_id=Users.user_roles.usro_user_id and  Users.roles.role_id=Users.user_roles.usro_role_id and Users.roles.role_name  in ('Cliente Regular','Cliente VIP' , 'Huésped' 
		,'Visitante' , 'Turista','Invitado' ,'Cliente de Negocios','Cliente de Eventos','Cliente de Vacaciones','Cliente de Lujo');
	
	 

    -- Inicializar el contador de usuarios procesados
    DECLARE @UserCount INT
    SET @UserCount = 0

    OPEN UserCursor
	--truncate table Users.user_members
    -- Recorrer los usuarios
    FETCH NEXT FROM UserCursor INTO @UserID

    WHILE @@FETCH_STATUS = 0
    BEGIN
     
		--print @UserID
		-- Generar datos aleatorios para la membresía
       SET @MembershipName = CASE WHEN RAND() < 0.25 THEN 'Silver'
                                   WHEN RAND() < 0.5 THEN 'Gold'
                                   WHEN RAND() < 0.75 THEN 'VIP'
                                   ELSE 'Wizard'
                              END
        SET @PromoteDate = DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE())
        SET @Points = CAST(RAND() * 100 AS SMALLINT)
        SET @Type = CASE WHEN RAND() < 0.5 THEN 'Active'
                         ELSE 'Expired'
                    END
        -- Insertar el registro de membresía
        INSERT INTO Users.user_members (usme_user_id, usme_memb_name, usme_promote_date, usme_points, usme_type)
        VALUES (@UserID, @MembershipName, @PromoteDate, @Points, @Type)        
        SET @UserCount = @UserCount + 1          -- Incrementar el contador de usuarios procesados                
		FETCH NEXT FROM UserCursor INTO @UserID  -- Obtener el siguiente usuario	
	END
  
    CLOSE UserCursor -- Cerrar y liberar el cursor
    DEALLOCATE UserCursor -- Cerrar y liberar el cursor

    PRINT 'Se insertaron ' + CAST(@UserCount AS NVARCHAR(10)) + ' registros de membresía.'
END
go


----28
-- Crear el procedimiento almacenado
CREATE OR ALTER PROCEDURE InsertHotelReviewsForClients
AS
BEGIN
    DECLARE @UserId INT
    DECLARE @HotelId INT
    DECLARE @ReviewText NVARCHAR(125)
    DECLARE @Rating TINYINT
    DECLARE @CreatedOn DATETIME
    
    -- Declarar un cursor para obtener los usuarios de tipo cliente
    DECLARE client_cursor CURSOR FOR
    SELECT user_id
    FROM Users.users
    WHERE user_type = 'C'
    
    -- Abrir el cursor
    OPEN client_cursor
    
    -- Inicializar variables
    FETCH NEXT FROM client_cursor INTO @UserId
    
    -- Recorrer los usuarios de tipo cliente
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Seleccionar un hotel al azar (puedes personalizar esta lógica)
        SELECT TOP 1 @HotelId = hotel_id
        FROM Hotel.Hotels
        ORDER BY NEWID()
        
        -- Generar una puntuación aleatoria entre 1 y 5
        SET @Rating = CAST(1 + (CAST(RAND() * 5 AS INT)) AS TINYINT)
        
        -- Generar una opinión basada en la puntuación
        SET @ReviewText = CASE
            WHEN @Rating = 1 THEN 'Muy malo'
            WHEN @Rating = 2 THEN 'Regular'
            WHEN @Rating = 3 THEN 'Bueno'
            WHEN @Rating = 4 THEN 'Muy bueno'
            WHEN @Rating = 5 THEN 'Excelente'
            ELSE 'Sin opinión'
        END
        
        -- Generar una fecha y hora de creación aleatoria en el rango de los últimos 30 días
        SET @CreatedOn = DATEADD(DAY, -1 * CAST(RAND() * 30 AS INT), GETDATE())
        
        -- Insertar la opinión en la tabla Hotel.Hotel_Reviews
        INSERT INTO Hotel.Hotel_Reviews (hore_user_review, hore_rating, hore_created_on, hore_user_id, hore_hotel_id)
        VALUES (@ReviewText, @Rating, @CreatedOn, @UserId, @HotelId)
        
        -- Obtener el siguiente usuario de tipo cliente
        FETCH NEXT FROM client_cursor INTO @UserId
    END
    
    -- Cerrar y deshacer el cursor
    CLOSE client_cursor
    DEALLOCATE client_cursor
END
go


----29
-- Crear el procedimiento almacenado
CREATE or alter  PROCEDURE GenerateEmployeeSalaryHistory
AS
BEGIN
    DECLARE @EmpId INT
    DECLARE @RateChangeDate DATETIME
    DECLARE @Salary MONEY
    DECLARE @PayFrequence INT
    DECLARE @ModifiedDate DATETIME
    DECLARE @JobRole NVARCHAR(55)
    
    -- Declarar un cursor para obtener los empleados y sus roles
    DECLARE emp_cursor CURSOR FOR
    SELECT e.emp_id, j.joro_name
    FROM HR.employee e
    JOIN HR.job_role j ON e.emp_joro_id = j.joro_id
    
    -- Abrir el cursor
    OPEN emp_cursor
    
    -- Inicializar variables
    FETCH NEXT FROM emp_cursor INTO @EmpId, @JobRole
    
    -- Recorrer los empleados
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar una fecha de cambio de tarifa aleatoria en el rango de los últimos 365 días
        SET @RateChangeDate = DATEADD(DAY, -1 * CAST(RAND() * 365 AS INT), GETDATE())
        
        -- Asignar salarios de acuerdo al rol
        SET @Salary = 
            CASE
                WHEN @JobRole = 'Recepcionista' THEN 4000
                WHEN @JobRole = 'Botones' THEN 3500
                WHEN @JobRole = 'Ama de llaves' THEN 3500
                WHEN @JobRole = 'Camarero' THEN 3000
                WHEN @JobRole = 'Cocinero' THEN 4200
                WHEN @JobRole = 'Auxiliar de cocina' THEN 3800
                WHEN @JobRole = 'Friega platos' THEN 3200
                WHEN @JobRole = 'Personal de seguridad' THEN 4200
                WHEN @JobRole = 'Animador' THEN 4000
                WHEN @JobRole = 'Socorrista' THEN 3800
                WHEN @JobRole = 'Masajista' THEN 3500
                WHEN @JobRole = 'Hotel manager' THEN 7000
                WHEN @JobRole = 'Personal de mantenimiento' THEN 4000
                WHEN @JobRole = 'Conserje' THEN 3600
                WHEN @JobRole = 'Agente de reservas' THEN 3800
                WHEN @JobRole = 'Entrenador' THEN 3500
                ELSE 0 -- Si el rol no coincide con ninguno, el salario será 0
            END
        
        -- Generar una frecuencia de pago aleatoria entre 1 y 4 (por ejemplo, mensual, quincenal)
        SET @PayFrequence = CAST(1 + (CAST(RAND() * 4 AS INT)) AS INT)
        
        -- Generar una fecha y hora de modificación aleatoria en el rango de los últimos 30 días
        SET @ModifiedDate = DATEADD(DAY, -1 * CAST(RAND() * 30 AS INT), GETDATE())
        
        -- Insertar el historial de salario en la tabla HR.employee_pay_history
        INSERT INTO HR.employee_pay_history (ephi_emp_id, ephi_rate_change_date, ephi_rate_salary, ephi_pay_frequence, ephi_modified_date)
        VALUES (@EmpId, @RateChangeDate, @Salary, @PayFrequence, @ModifiedDate)
        
        -- Obtener el siguiente empleado y su rol
        FETCH NEXT FROM emp_cursor INTO @EmpId, @JobRole
    END
    
    -- Cerrar y deshacer el cursor
    CLOSE emp_cursor
    DEALLOCATE emp_cursor
END
go

-----30
----------------**********************************--------------------
-- Crear el procedimiento almacenado
CREATE or alter  PROCEDURE AssignEmployeeAttributesAndShifts
AS
BEGIN
    -- Declarar una tabla temporal para almacenar los roles y sus departamentos correspondientes
    DECLARE @RoleDepartment TABLE (
        RoleName NVARCHAR(50),
        DepartmentName NVARCHAR(50)
    )

    -- Insertar los mapeos de roles a departamentos
    INSERT INTO @RoleDepartment (RoleName, DepartmentName)
    VALUES
        ('Recepcionista', 'Departamento de Recepcion'),
        ('Botones', 'Departamento de Recepcion'),
        ('Agente de Reservas', 'Departamento de Recepcion'),
        ('Ama de Llaves', 'Departamento de Limpieza'),
        ('Camarero', 'Departamento de Cocina'),
        ('Cocinero', 'Departamento de Cocina'),
        ('Auxiliar de Cocina', 'Departamento de Cocina'),
        ('Friega Platos', 'Departamento de Cocina'),
        ('Personal de Seguridad', 'Departamento de Seguridad'),
        ('Animador', 'Departamento de Contabilidad y Finanzas'),
        ('Hotel Manager', 'Departamento de Contabilidad y Finanzas'),
        ('Socorrista', 'Departamento de Spa'),
        ('Masajista', 'Departamento de Spa'),
        ('Personal de Mantenimiento', 'Departamento de Mantenimiento'),
        ('Conserje', 'Departamento de Direccion'),
        ('Entrenador', 'Departamento de Fitness')

    -- Declarar variables
    DECLARE @EmployeeID INT
    DECLARE @ShiftID INT
    DECLARE @StartDate DATETIME
    DECLARE @EndDate DATETIME

    -- Recorrer todos los empleados
    DECLARE employee_cursor CURSOR FOR
    SELECT emp_id, emp_hire_date FROM HR.employee

    OPEN employee_cursor
    FETCH NEXT FROM employee_cursor INTO @EmployeeID, @StartDate

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Asignar aleatoriamente un turno a cada empleado
        SET @ShiftID = (SELECT TOP 1 shift_id FROM HR.shift ORDER BY NEWID())

        -- Obtener el departamento correspondiente al rol del empleado
        DECLARE @DepartmentName NVARCHAR(50)
        SELECT @DepartmentName = DepartmentName FROM @RoleDepartment WHERE RoleName = (SELECT joro_name FROM HR.job_role WHERE joro_id = (SELECT emp_joro_id FROM HR.employee WHERE emp_id = @EmployeeID))

        -- Obtener la fecha de finalización desde la tabla de empleados
        SELECT @EndDate = GETDATE() FROM HR.employee WHERE emp_id = @EmployeeID

        -- Insertar un solo registro en la tabla de historial de departamento para cada empleado
        INSERT INTO HR.employee_department_history (edhi_emp_id, edhi_start_date, edhi_end_date, edhi_modified_date, edhi_dept_id, edhi_shift_id)
        VALUES (@EmployeeID, @StartDate, @EndDate, GETDATE(), (SELECT dept_id FROM HR.department WHERE dept_name = @DepartmentName), @ShiftID)

        FETCH NEXT FROM employee_cursor INTO @EmployeeID, @StartDate
    END

    CLOSE employee_cursor
    DEALLOCATE employee_cursor
END
go

-----31
-------------------------------------**************************************-------------------------------
CREATE or alter  PROCEDURE InsertRandomFacilities @NumFacilities INT
AS
BEGIN
  DECLARE @Counter INT = 0;

  WHILE @Counter < @NumFacilities
  BEGIN
    -- Generar datos aleatorios para la inserción
    DECLARE @RandomUserID INT;
    SELECT TOP 1 @RandomUserID = user_id FROM Users.users WHERE user_type = 'T' ORDER BY NEWID();

    DECLARE @RandomCategoryID INT;
    SELECT TOP 1 @RandomCategoryID = cagro_id FROM Master.category_group WHERE cagro_type = 'facility' ORDER BY NEWID();

    DECLARE @RandomHotelID INT;
    SELECT TOP 1 @RandomHotelID = hotel_id FROM Hotel.Hotels ORDER BY NEWID();

    -- Generar un número aleatorio para max_number (entre 1 y 10)
    DECLARE @RandomMaxNumber INT = CAST((RAND() * 10 + 1) AS INT);

    -- Asignar measure_unit en función del número aleatorio
    DECLARE @RandomMeasureUnit NVARCHAR(15);
    IF @RandomMaxNumber = 1 OR @RandomMaxNumber = 2 OR @RandomMaxNumber = 3
      SET @RandomMeasureUnit = 'beds';
    ELSE
      SET @RandomMeasureUnit = 'people';

    -- Insertar el nuevo registro en la tabla "Hotel.Facilities"
    INSERT INTO Hotel.Facilities (
      faci_name,
      faci_description,
      faci_max_number,
      faci_measure_unit,
      faci_room_number,
      faci_startdate,
      faci_enddate,
      faci_low_price,
      faci_high_price,
      faci_rate_price,
      faci_expose_price,
      faci_discount,
      faci_tax_rate,
      faci_cagro_id,
      faci_hotel_id,
      faci_user_id
    )
    VALUES (
      'NombreFacility' + CAST(@Counter AS NVARCHAR(5)),
      'Descripción aleatoria',
      @RandomMaxNumber,
      @RandomMeasureUnit,
      'Habitación' + CAST(@Counter AS NVARCHAR(5)),
      GETDATE(),
      DATEADD(DAY, 30, GETDATE()),
      CAST((RAND() * 100 + 50) AS MONEY),
      CAST((RAND() * 200 + 100) AS MONEY),
      NULL,
      CAST((RAND() * 2 + 1) AS TINYINT),
      NULL,
      NULL,
      @RandomCategoryID,
      @RandomHotelID,
      @RandomUserID
    );

    SET @Counter = @Counter + 1;
  END;
END;
go


-------32
CREATE PROCEDURE InsertarBonusPoints
AS
BEGIN
    
    DECLARE @Count INT = 1;
    
    WHILE @Count <= 1000
    BEGIN
        DECLARE @ubpo_user_id INT = @Count;
        DECLARE @ubpo_total_points SMALLINT = CAST(RAND() * 91 + 10 AS SMALLINT);
        DECLARE @ubpo_bonus_type NCHAR(1) = CASE WHEN RAND() < 0.5 THEN 'D' ELSE 'C' END;
        DECLARE @ubpo_created_on DATETIME = DATEADD(DAY, CAST(RAND() * 1461 AS INT), '2019-09-01');

        INSERT INTO Users.bonus_points (ubpo_user_id, ubpo_total_points, ubpo_bonus_type, ubpo_created_on)
        VALUES (@ubpo_user_id, @ubpo_total_points, @ubpo_bonus_type, @ubpo_created_on);

        SET @Count = @Count + 1;
    END;
END;
go

-------34
CREATE or alter PROCEDURE Users.usp_InsertRandomUserData
AS
BEGIN

DECLARE @uspa_user_id INT = 1;
DECLARE @uspa_passwordHash VARCHAR(128);
DECLARE @uspa_passwordSalt VARCHAR(10);

WHILE @uspa_user_id <= 1000
BEGIN
SELECT @uspa_passwordHash = CRYPT_GEN_RANDOM(128), @uspa_passwordSalt = CRYPT_GEN_RANDOM(10);

INSERT INTO Users.user_password (uspa_passwordHash, uspa_passwordSalt)
VALUES ( @uspa_passwordHash, @uspa_passwordSalt);

SET @uspa_user_id = @uspa_user_id + 1;
END;
END;
go


-------35
CREATE PROCEDURE InsertarRegistrosAleatorios
AS
BEGIN
    DECLARE @contador INT = 1;

    WHILE @contador <= 1000
    BEGIN
        DECLARE @cart_emp_id INT;
        DECLARE @cart_vepro_id INT;
		DECLARE @cart_order_qty INT;
        DECLARE @cart_modified_date DATETIME;

        -- Generar valores aleatorios
        SET @cart_emp_id = CAST((RAND() * 5) + 1 AS INT); -- Entre 1 y 1000
        SET @cart_vepro_id = CAST((RAND() * 50) + 1 AS INT);  -- Entre 1 y 50
		SET @cart_order_qty = CAST((RAND() * 5) + 1 AS INT);
        SET @cart_modified_date = DATEADD(DAY, CAST((RAND() * 365) AS INT), '2022-09-01'); -- Entre 2019-09-01 y 2023-09-19

        INSERT INTO purchasing.cart (cart_emp_id, cart_vepro_id, cart_order_qty, cart_modified_date)
        VALUES (@cart_emp_id, @cart_vepro_id, @cart_order_qty, @cart_modified_date);

        SET @contador = @contador + 1;
    END;
END;

go


--------------36
-- Crear el procedimiento almacenado
CREATE PROCEDURE GenerarRegistrosPurchaseOrder
AS
BEGIN
    DECLARE @contador INT = 1;

    WHILE @contador <= 50
    BEGIN
        DECLARE @pohe_vendor_id INT;
        DECLARE @pohe_emp_id INT;

        -- Generar valores aleatorios para pohe_vendor_id y pohe_emp_id entre 1 y 5
        SET @pohe_vendor_id = CAST((RAND() * 5) + 4 AS INT);
        SET @pohe_emp_id = CAST((RAND() * 5) + 1 AS INT);

        INSERT INTO purchasing.purchase_order_header (pohe_number, pohe_status, pohe_order_date, pohe_subtotal, pohe_tax, pohe_emp_id, pohe_vendor_id, pohe_pay_type)
        VALUES (
            'PO-' + CAST(@contador AS NVARCHAR(10)),
            CAST((RAND() * 5) + 1 AS TINYINT), -- Status aleatorio entre 1 y 5
            DATEADD(DAY, -CAST((RAND() * 365) AS INT), GETDATE()), -- Fecha aleatoria en los últimos 365 días
            ROUND(RAND() * 1000, 2), -- Subtotal aleatorio entre 0 y 1000
            0.1, -- Impuesto fijo en 0.1
            @pohe_emp_id,
            @pohe_vendor_id,
            CASE WHEN RAND() < 0.5 THEN 'TR' ELSE 'CA' END -- Aleatoriamente 'TR' o 'CA' para pohe_pay_type
        );

        SET @contador = @contador + 1;
    END;
END;
go
-- Crear el procedimiento almacenado
-- Crear el procedimiento almacenado  37
CREATE PROCEDURE GenerarRegistrosStockDetail
AS
BEGIN
    DECLARE @contador INT = 1;

    WHILE @contador <= 50
    BEGIN
        DECLARE @stod_stock_id INT;
        DECLARE @stod_pohe_id INT;
        DECLARE @stod_faci_id INT;

        -- Generar valores aleatorios para stod_stock_id, stod_pohe_id y stod_faci_id
        SET @stod_stock_id = CAST((RAND() * 20) + 1 AS INT); -- Valores entre 1 y 20
        SET @stod_pohe_id = CAST((RAND() * 50) + 1 AS INT); -- Valores entre 1 y 50
        SET @stod_faci_id = CAST((RAND() * 50) + 1 AS INT); -- Valores entre 1 y 50

        -- Generar valores aleatorios para stod_status como cadenas de caracteres
        DECLARE @stod_status NCHAR(2);
        SET @stod_status = CASE 
            WHEN RAND() < 0.25 THEN '1'
            WHEN RAND() < 0.5 THEN '2'
            WHEN RAND() < 0.75 THEN '3'
            ELSE '4'
        END;

        INSERT INTO purchasing.stock_detail (stod_stock_id, stod_barcode_number, stod_status, stod_notes, stod_faci_id, stod_pohe_id)
        VALUES (
            @stod_stock_id,
            'Barcode-' + CAST(@contador AS NVARCHAR(10)),
            @stod_status,
            'Notas para el producto ' + CAST(@contador AS NVARCHAR(10)),
            @stod_faci_id,
            @stod_pohe_id
        );

        SET @contador = @contador + 1;
    END;
END;

go

-- Crear el procedimiento almacenado
CREATE PROCEDURE InsertarRegistrosPurchaseOrderDetail
AS
BEGIN
    DECLARE @contador INT = 1;

    WHILE @contador <= 300
    BEGIN
        DECLARE @pode_pohe_id INT;
        DECLARE @pode_stock_id INT;

        -- Generar valores aleatorios para pode_pohe_id y pode_stock_id
        SET @pode_pohe_id = CAST((RAND() * 50) + 1 AS INT); -- Valores entre 1 y 50
        SET @pode_stock_id = CAST((RAND() * 20) + 1 AS INT); -- Valores entre 1 y 20

        -- Generar valores aleatorios para pode_order_qty, pode_price, pode_received_qty, y pode_rejected_qty
        DECLARE @pode_order_qty SMALLINT;
        SET @pode_order_qty = CAST((RAND() * 100) + 1 AS SMALLINT); -- Valores entre 1 y 100

        DECLARE @pode_price MONEY;
        SET @pode_price = ROUND(RAND() * 100, 2); -- Valores entre 0 y 100 con 2 decimales

        DECLARE @pode_received_qty DECIMAL(8, 2);
        SET @pode_received_qty = CAST((RAND() * 50) AS DECIMAL(8, 2)); -- Valores entre 0 y 50 con 2 decimales

        DECLARE @pode_rejected_qty DECIMAL(8, 2);
        SET @pode_rejected_qty = CAST((RAND() * @pode_received_qty) AS DECIMAL(8, 2)); -- Valores entre 0 y puede_received_qty con 2 decimales

        INSERT INTO purchasing.purchase_order_detail (pode_pohe_id, pode_order_qty, pode_price, pode_received_qty, pode_rejected_qty, pode_stock_id)
        VALUES (
            @pode_pohe_id,
            @pode_order_qty,
            @pode_price,
            @pode_received_qty,
            @pode_rejected_qty,
            @pode_stock_id
        );

        SET @contador = @contador + 1;
    END;
END;
go

CREATE PROCEDURE InsertarOfertasreservaAleatorias
AS
BEGIN
    DECLARE @Counter INT = 1;

    WHILE @Counter <= 20
    BEGIN
        INSERT INTO Booking.special_offers (spof_name, spof_description, spof_type, spof_discount, spof_start_date, spof_end_date, spof_min_qty, spof_max_qty)
        VALUES
            ('Oferta ' + CAST(@Counter AS NVARCHAR(2)), 'Descripción de la oferta ' + CAST(@Counter AS NVARCHAR(2)), 
            'T', (RAND() * 10), 
            DATEADD(day, CAST(RAND() * 365 AS INT), '2022-09-01'), 
            DATEADD(day, CAST(RAND() * 365 AS INT), '2023-09-01'), 
            CASE WHEN @Counter % 4 = 0 THEN @Counter ELSE 0 END, 
            CASE WHEN @Counter % 5 = 0 THEN @Counter ELSE null END);

        SET @Counter = @Counter + 1;
    END;
END;
go
CREATE PROCEDURE InsertarRegistrosBookingOrders
AS
BEGIN
    DECLARE @Counter INT = 1;

    WHILE @Counter <= 100
    BEGIN
        -- Generar valores aleatorios para algunos campos
        DECLARE @OrderNumber NVARCHAR(55);
        SET @OrderNumber = 'ORD-' + CAST(@Counter AS NVARCHAR(3));

        DECLARE @OrderDate DATETIME;
        SET @OrderDate = DATEADD(day, -RAND() * 365, GETDATE());

        DECLARE @ArrivalDate DATETIME;
        SET @ArrivalDate = DATEADD(day, CAST(RAND() * 365 AS INT), GETDATE());

        DECLARE @TotalRoom SMALLINT;
        SET @TotalRoom = CAST(RAND() * 10 AS SMALLINT);

        DECLARE @TotalGuest SMALLINT;
        SET @TotalGuest = CAST(RAND() * 5 AS SMALLINT);

        DECLARE @Discount MONEY;
        SET @Discount = RAND() * 100;

        DECLARE @TotalTax MONEY;
        SET @TotalTax = RAND() * 50;

        DECLARE @TotalAmount MONEY;
        SET @TotalAmount = RAND() * 500;

        DECLARE @DownPayment MONEY;
        SET @DownPayment = RAND() * 100;

        DECLARE @PayType NCHAR(2);
        SET @PayType = CASE WHEN RAND() < 0.5 THEN 'CR' ELSE 'C' END;

        DECLARE @IsPaid NCHAR(2);
        SET @IsPaid = CASE WHEN RAND() < 0.3 THEN 'DP' WHEN RAND() < 0.6 THEN 'P' ELSE 'R' END;

        DECLARE @Type NVARCHAR(15);
        SET @Type = CASE WHEN RAND() < 0.4 THEN 'T' WHEN RAND() < 0.8 THEN 'C' ELSE 'I' END;

        DECLARE @CardNumber NVARCHAR(25);
        SET @CardNumber = NULL;

        DECLARE @MemberType NVARCHAR(15);
        SET @MemberType = NULL;

        DECLARE @Status NVARCHAR(15);
        SET @Status = CASE WHEN RAND() < 0.2 THEN 'BOOKING' WHEN RAND() < 0.4 THEN 'CHECKIN' WHEN RAND() < 0.6 THEN 'CHECKOUT' WHEN RAND() < 0.8 THEN 'CLEANING' ELSE 'CANCELED' END;

        DECLARE @UserId INT;
        SET @UserId = 300 + CAST(RAND() * 700 AS INT);

        --DECLARE @HotelId INT;
        --SET @HotelId = 1 + CAST(RAND() * 5 AS INT);

        -- Insertar el registro
        INSERT INTO Booking.booking_orders (
            boor_order_number, boor_order_date, boor_arrival_date, boor_total_room, 
            boor_total_guest, boor_discount, boor_total_tax, boor_total_ammount, 
            boor_down_payment, boor_pay_type, boor_is_paid, boor_type, boor_cardnumber, 
            boor_member_type, boor_status, boor_user_id
        )
        VALUES (
            @OrderNumber, @OrderDate, @ArrivalDate, @TotalRoom, @TotalGuest, @Discount, 
            @TotalTax, @TotalAmount, @DownPayment, @PayType, @IsPaid, @Type, @CardNumber, 
            @MemberType, @Status, @UserId
        );

        SET @Counter = @Counter + 1;
    END;
END;
go
-- Crear el procedimiento almacenado
CREATE or alter PROCEDURE InsertarRegistrosPaymentGateway
AS
BEGIN
    DECLARE @Counter INT = 1;

    WHILE @Counter <= 10
    BEGIN
        INSERT INTO Payment.payment_gateway (paga_entity_id, paga_code, paga_name)
        VALUES (@Counter, 'Code' + CAST(@Counter AS NVARCHAR(10)), 'Name' + CAST(@Counter AS NVARCHAR(10)));

        SET @Counter = @Counter + 1;
    END;
END;
go



-- Crear el procedimiento almacenado
CREATE PROCEDURE InsertarRegistrosUserAccounts
AS
BEGIN
    DECLARE @Counter INT = 1;

    WHILE @Counter <= 1000
    BEGIN
        DECLARE @UserID INT;
        SET @UserID = (@Counter % 1000) + 1; -- Asumiendo 1000 usuarios

        INSERT INTO Payment.user_accounts (usac_entity_id, usac_user_id, usac_account_number, usac_saldo, usac_type, usac_expmonth, usac_expyear)
        VALUES (@Counter % 10 + 1, @UserID, 'Account' + CAST(@Counter AS NVARCHAR(10)), 0.00, 'debet', NULL, NULL);

        SET @Counter = @Counter + 1;
    END;
END;
go
-- Crear el procedimiento almacenado
CREATE PROCEDURE InsertarRegistrosPaymentTransaction
AS
BEGIN
    DECLARE @Counter INT = 1;

    WHILE @Counter <= 1000
    BEGIN
        DECLARE @UserID INT;
        SET @UserID = @Counter; -- Suponiendo que los IDs de usuario son del 1 al 1000

        INSERT INTO Payment.payment_transaction (patr_trx_number, patr_type, patr_user_id)
        VALUES ('Transaction' + CAST(@Counter AS NVARCHAR(10)), 'TP', @UserID);

        SET @Counter = @Counter + 1;
    END;
END;
go





EXEC AssignRandomRolesToUsersEmpleados
EXEC AssignRandomRolesToUsersClientes
exec InsertUserMemberships
EXEC Users.usp_InsertRandomUserData;
exec InsertarBonusPoints
EXEC InsertHotelReviewsForClients
EXEC GenerateEmployeeSalaryHistory
EXEC AssignEmployeeAttributesAndShifts
EXEC InsertRandomFacilities 50;
EXEC InsertarRegistrosAleatorios;
EXEC GenerarRegistrosPurchaseOrder;
EXEC GenerarRegistrosStockDetail;
EXEC InsertarRegistrosPurchaseOrderDetail;
exec InsertarOfertasreservaAleatorias
exec InsertarRegistrosBookingOrders;
exec InsertarRegistrosPaymentGateway
EXEC InsertarRegistrosUserAccounts;
EXEC InsertarRegistrosPaymentTransaction;
INSERT INTO Users.roles (role_name) VALUES ('Gerente');
go



-----------------------------------------------------------------------------------------------------



---------------------------------------**********************************************----------------------------------
 --6.1 menus    37
INSERT INTO Resto.resto_menus(reme_name, reme_description, reme_price, reme_status, reme_modified_date, reme_type, reme_faci_id) VALUES 
('Causa de Pollo','Papa amarilla prensada aderezada con limon y crema de aji amarillo peruano rellena con pollo con salsa huancaina',70,'Disponible',GETDATE(),'Entradas Frias',1),
('Papines a la Huancaina','Papas cocidas al vapor en sabrosa salsa huancaina, con todos los sabores peruanos, coronada con huevo, aceitunas y huevo',70,'Disponible',GETDATE(),'Entradas Frias',7),
('Carpaccio de Surubí','Láminas de pescado del río marinadas en crema de aji amarillo acompañado de un corte fino de queso parmesano y alcaparras',70,'Disponible',GETDATE(),'Entradas Frias',11),
('Tataki de Salmon','Láminas de salmon sellado y marinadas en salsa oriental sobre laminas de palta, reduccion de soya y mayonesa al wasabi',95,'Disponible',GETDATE(),'Entradas Frias',19),
('Pulpo al Olivo','Tiras de pulpo cocido a fuego lento con crema de aceitunas y pimientos soasados, palta sobre abanico de papas andinas',85,'Disponible',GETDATE(),'Entradas Frias',28),
('Ensalada de Huerto','Hojas frescas de lechuga, rabanitos, laminas de palta, queso de la region y tomate, marinadas en vinagreta de naranja',70,'Disponible',GETDATE(),'Entradas Frias',50),
('Ensalada Tropical','Frescas hojas de lechuga del huerto, gajos de naranja, tomates cherrys, dados de queso mozzarella, huevo de codorniz y langostinos en vinagreta de piña',80,'Disponible',GETDATE(),'Entradas Frias',44),
('Dieta de Pollo','Suave sopa de pollo, cabellos de angel, toques de vegetales y dados de pollo',50,'Disponible',GETDATE(),'Entradas Calientes',35),
('Sopa de Maní','Tipica sopa nacional, con carne de res y papas al hilo',55,'Disponible',GETDATE(),'Entradas Calientes',17),
('Lomo Fino en Salsa de Hongos','Medallon de lomo en salsa de hongos silvestres acompañado de puré de papas y vegetales',110,'Disponible',GETDATE(),'Fondos',22),
('Bife al Grill','Bife de res al grill, chimichurri de pimientos del piquillo con papas fritas y salsa ranch',130,'Disponible',GETDATE(),'Fondos',47),
('Lomo Saltado','Tiras de lomo saltados en salsa de soya estilo peruano con arroz y papas fritas',110,'Disponible',GETDATE(),'Fondos',36),
('Pollo a la Florentina','Suprema de pollo al grill, en salsa pomodoro al gratin sobre arroz florentina',98,'Disponible',GETDATE(),'Fondos',39),
('Salmon Teriyaki','Filete de salmon glaseado en salsa teriyaki acompañado de chaufa de quinua y hojas',110,'Disponible',GETDATE(),'Fondos',21),
('Spaghetti','A la crema pon pollo en dados y tomillo flameados al pisco',65,'Disponible',GETDATE(),'Fondos',42),
('Silpancho','Tipico plato Boliviano renovado a nuestro estilo',99,'Disponible',GETDATE(),'Fondos',26);
go



/*select Master.policy.poli_id,Master.policy.poli_description,Master.category_group.cagro_id,
  Master.category_group.cagro_description,Master.policy_category_group.poca_cagro_id,Master.policy_category_group.poca_poli_id 
  from Master.policy,Master.category_group,Master.policy_category_group
  */ 
  
  /*SELECT DISTINCT
    p.poli_id,
    p.poli_description,
    cg.cagro_id,
    cg.cagro_description,
    pcg.poca_cagro_id,
    pcg.poca_poli_id
FROM
    Master.policy p
INNER JOIN
    Master.policy_category_group pcg ON p.poli_id = pcg.poca_poli_id
INNER JOIN
    Master.category_group cg ON pcg.poca_cagro_id = cg.cagro_id;*/


/*select *from Resto.resto_menus*/

---------****************************----------
--select *
--from HR.employee
--select *
--from hr.job_role
--select *
--from hr.employee_pay_history




--DROP PROCEDURE AssignEmployeeAttributesAndShifts

--SELECT * FROM HR.employee_department_history
--select * from hr.employee
--select d.dept_name
--from hr.department d, hr.employee e , hr.job_role j, hr.employee_department_history edh
--where e.emp_id = 64 and d.dept_id=edh.edhi_dept_id and edh.edhi_emp_id=e.emp_id and e.emp_joro_id=j.joro_id




