CREATE TABLE chemicals (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  formula VARCHAR(50),
  notes TEXT
);

ALTER TABLE things ADD COLUMN chemical_id int(11);
ALTER TABLE things ADD CONSTRAINT fk_things_chemicals FOREIGN KEY (chemical_id) REFERENCES chemicals(id);

create table containers (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `volume` int(2),
  `notes` text,
  PRIMARY KEY (`id`)
);

create table containers_things (
        `container_id` int(11) NOT NULL,
        `thing_id` int(11) NOT NULL,
        FOREIGN KEY (container_id) REFERENCES containers (id),
        FOREIGN KEY (thing_id) REFERENCES things(id)
);

CREATE TABLE filling_multipliers (
  id int(11) AUTO_INCREMENT PRIMARY KEY,
  chemical_id int(11) NOT NULL,
  container_id int(11) NOT NULL,
  multiplier DECIMAL(5,2) NOT NULL, -- e.g., 1.60 for 60% more
  FOREIGN KEY (chemical_id) REFERENCES chemicals(id),
  FOREIGN KEY (container_id) REFERENCES containers(id),
  UNIQUE (chemical_id, container_id)
);

insert into chemicals values (1, 'Azoto', 'N');
insert into filling_multipliers values (1, 1, 

insert into containers values (1, 5, '');
insert into containers values (1, 10, '');
insert into containers values (1, 25, '');
insert into containers values (1, 50, '');
insert into containers values (1, 90, '');
insert into containers values (1, 120, '');
insert into containers values (1, 200, '');


alter table organizations drop column division;
alter table operations drop column division_id;

alter table organizations add column `with_labs` bool default false after `pricing`; 

CREATE TABLE `labs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_labs_organizations` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
);

alter table operations add column lab_id int(11) unsigned after `ddt_id`;
ALTER TABLE operations ADD CONSTRAINT `operations_labfk` FOREIGN KEY (lab_id) REFERENCES labs(id);

UPDATE organizations set with_labs = true where id=255;

insert into labs values (0, 255, 'P2 Graphite - U.e.5');
insert into labs values (0, 255, 'P3 Nanotube Quadrilatero - U.e.5');
insert into labs values (0, 255, 'P3 Nanotube Tecnica - U.e.5');
insert into labs values (0, 255, 'P4 Diamond - U.e.5');
insert into labs values (0, 255, 'P5 Fullerene - U.e.5');
insert into labs values (0, 255, 'P6 Graphene - U.e.5');
insert into labs values (0, 255, 'P7 Carbon - U.e.5');
