-- ALTER TABLE things ADD COLUMN dewars text;
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT
);

ALTER TABLE operations
ADD COLUMN department_id INT,
ADD CONSTRAINT fk_operation_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE delegations
ADD COLUMN department_id INT,
ADD CONSTRAINT fk_delegation_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE;
