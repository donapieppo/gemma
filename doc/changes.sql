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
