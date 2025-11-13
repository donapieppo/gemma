-- ALTER TABLE things ADD COLUMN dewars text;
CREATE TABLE `destinations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) unsigned NOT NULL,
  `building` varchar(255) NOT NULL,
  `detail` varchar(255),
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
  -- KEY `organization_id` (`organization_id`),
  -- CONSTRAINT `buildings_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
);

insert into `destinations` values (0, 255, 'UE5', 'P0', '');
insert into `destinations` values (0, 255, 'UE5', 'P1', '');
insert into `destinations` values (0, 255, 'UE5', 'P2', '');
insert into `destinations` values (0, 255, 'UE5', 'P3', '');
insert into `destinations` values (0, 255, 'UE5', 'P4', '');
insert into `destinations` values (0, 255, 'UE5', 'P5', '');
insert into `destinations` values (0, 255, 'UE5', 'P6', '');
insert into `destinations` values (0, 255, 'UE5', 'P7', '');
insert into `destinations` values (0, 255, 'UE4', 'Corpo C/D', '');
insert into `destinations` values (0, 255, 'UE4', 'Corpo A/B', '');
insert into `destinations` values (0, 255, 'UE6', '');

ALTER TABLE operations
ADD COLUMN destination_id INT(11),
ADD CONSTRAINT fk_operation_destination
    FOREIGN KEY (destination_id)
    REFERENCES destinations(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE delegations
ADD COLUMN destination_id INT(11),
ADD CONSTRAINT fk_delegation_destination
    FOREIGN KEY (destination_id)
    REFERENCES destinations(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

CREATE TABLE departments (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT
);

ALTER TABLE operations
ADD COLUMN department_id INT(11),
ADD CONSTRAINT fk_operation_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE delegations
ADD COLUMN department_id INT(11),
ADD CONSTRAINT fk_delegation_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

     
