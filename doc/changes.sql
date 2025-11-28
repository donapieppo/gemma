alter table organizations drop with_labs;

-- ALTER TABLE things ADD COLUMN dewars text;
CREATE TABLE `picking_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_picking_points_organizations` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
);

insert into `picking_points` values (0, 255, 'UE5 - P0', '');
insert into `picking_points` values (0, 255, 'UE5 - P1', '');
insert into `picking_points` values (0, 255, 'UE5 - P2', '');
insert into `picking_points` values (0, 255, 'UE5 - P3', '');
insert into `picking_points` values (0, 255, 'UE5 - P4', '');
insert into `picking_points` values (0, 255, 'UE5 - P5', '');
insert into `picking_points` values (0, 255, 'UE5 - P6', '');
insert into `picking_points` values (0, 255, 'UE5 - P7', '');
insert into `picking_points` values (0, 255, 'UE4 - Corpo C/D', '');
insert into `picking_points` values (0, 255, 'UE4 - Corpo A/B', '');
insert into `picking_points` values (0, 255, 'UE6', '');

ALTER TABLE operations
ADD COLUMN picking_point_id INT(11),
ADD CONSTRAINT fk_operation_picking_point
    FOREIGN KEY (picking_point_id)
    REFERENCES picking_points(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE delegations
ADD COLUMN picking_point_id INT(11),
ADD CONSTRAINT fk_delegation_picking_point
    FOREIGN KEY (picking_point_id)
    REFERENCES picking_points(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

CREATE TABLE cost_centers (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    `organization_id` int(11) NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    CONSTRAINT `fk_cost_center_organizations` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
);

insert into `cost_centers` values (0, 255, 'CILDIC', '');
insert into `cost_centers` values (0, 255, 'Dipartimento di chimica', '');
insert into `cost_centers` values (0, 255, 'Dipartimento di chimica industriale', '');
insert into `cost_centers` values (0, 255, 'Dipartimento Fabit', '');

ALTER TABLE operations
ADD COLUMN cost_center_id INT(11),
ADD CONSTRAINT fk_operation_cost_center
    FOREIGN KEY (cost_center_id)
    REFERENCES cost_centers(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE delegations
ADD COLUMN cost_center_id INT(11),
ADD CONSTRAINT fk_delegation_cost_center
    FOREIGN KEY (cost_center_id)
    REFERENCES cost_centers(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

     
