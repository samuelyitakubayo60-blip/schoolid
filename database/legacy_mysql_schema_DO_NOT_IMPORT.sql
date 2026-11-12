CREATE DATABASE IF NOT EXISTS school_id_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_id_platform;

CREATE TABLE schools (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  school_code VARCHAR(60) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(40) NULL,
  address VARCHAR(255) NULL,
  logo_path VARCHAR(255) NULL,
  status ENUM('pending','active','suspended','rejected') NOT NULL DEFAULT 'pending',
  subscription_plan ENUM('monthly','yearly','custom','none') NOT NULL DEFAULT 'none',
  subscription_status ENUM('trial','active','past_due','expired','cancelled','none') NOT NULL DEFAULT 'none',
  subscription_starts_at DATETIME NULL,
  subscription_ends_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('active','disabled') NOT NULL DEFAULT 'active',
  is_platform_owner TINYINT(1) NOT NULL DEFAULT 0,
  last_login_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE roles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_key VARCHAR(80) NOT NULL UNIQUE,
  role_name VARCHAR(120) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE permissions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  permission_key VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY(role_id, permission_id),
  FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE school_memberships (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  status ENUM('active','disabled') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_school_user_role(school_id,user_id,role_id),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

CREATE TABLE user_permission_overrides (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  allowed TINYINT(1) NOT NULL,
  UNIQUE KEY uq_user_permission(school_id,user_id,permission_id),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE academic_years (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(80) NOT NULL,
  starts_on DATE NULL,
  ends_on DATE NULL,
  is_current TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_year_name(school_id,name),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE departments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(40) NULL,
  UNIQUE KEY uq_department(school_id,name),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE levels (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(40) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  UNIQUE KEY uq_level(school_id,name),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE programmes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  name VARCHAR(190) NOT NULL,
  code VARCHAR(60) NULL,
  category VARCHAR(80) NULL,
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE classes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  academic_year_id BIGINT UNSIGNED NULL,
  level_id BIGINT UNSIGNED NULL,
  programme_id BIGINT UNSIGNED NULL,
  name VARCHAR(100) NOT NULL,
  stream VARCHAR(80) NULL,
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(academic_year_id) REFERENCES academic_years(id) ON DELETE SET NULL,
  FOREIGN KEY(level_id) REFERENCES levels(id) ON DELETE SET NULL,
  FOREIGN KEY(programme_id) REFERENCES programmes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  admission_number VARCHAR(100) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  gender ENUM('female','male','other','not_stated') NOT NULL DEFAULT 'not_stated',
  date_of_birth DATE NULL,
  photo_path VARCHAR(255) NULL,
  status ENUM('active','inactive','graduated','transferred') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_school_admission(school_id,admission_number),
  INDEX idx_student_name(school_id,last_name,first_name),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_guardians (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  guardian_name VARCHAR(190) NOT NULL,
  relationship_to_student VARCHAR(80) NULL,
  phone VARCHAR(40) NULL,
  email VARCHAR(190) NULL,
  notes TEXT NULL,
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_guardian_student(school_id,student_id)
) ENGINE=InnoDB;

CREATE TABLE student_enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  class_id BIGINT UNSIGNED NOT NULL,
  academic_year_id BIGINT UNSIGNED NOT NULL,
  enrollment_status ENUM('enrolled','completed','withdrawn','transferred') NOT NULL DEFAULT 'enrolled',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_enrollment(student_id,class_id,academic_year_id),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY(academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE id_cards (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  qr_token CHAR(64) NOT NULL UNIQUE,
  design_json JSON NULL,
  issued_at DATETIME NULL,
  expires_at DATETIME NULL,
  status ENUM('active','revoked','expired') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE,
  FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_card_student(school_id,student_id)
) ENGINE=InnoDB;

CREATE TABLE school_settings (
  school_id BIGINT UNSIGNED PRIMARY KEY,
  card_front_json JSON NULL,
  card_back_json JSON NULL,
  public_fields_json JSON NULL,
  card_width_mm DECIMAL(6,2) NOT NULL DEFAULT 85.60,
  card_height_mm DECIMAL(6,2) NOT NULL DEFAULT 53.98,
  academic_label VARCHAR(100) NULL,
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  school_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(100) NULL,
  entity_id BIGINT UNSIGNED NULL,
  ip_address VARCHAR(45) NULL,
  details_json JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_school_time(school_id,created_at),
  FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE SET NULL,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO roles(role_key,role_name) VALUES
 ('school_admin','School Administrator'),
 ('department_head','Department Head'),
 ('class_teacher','Class Teacher'),
 ('card_officer','ID Card Officer'),
 ('viewer','Read-only Viewer');

INSERT IGNORE INTO permissions(permission_key,description) VALUES
 ('school.settings.manage','Manage school details and card design'),
 ('staff.manage','Create staff and assign roles'),
 ('students.view','View student records'),
 ('students.create','Register students'),
 ('students.edit','Edit student records'),
 ('students.delete','Delete student records'),
 ('guardians.view','View private guardian information'),
 ('academics.manage','Manage departments, levels, programmes, classes and years'),
 ('cards.create','Generate and print ID cards'),
 ('cards.revoke','Revoke ID cards'),
 ('audit.view','View audit logs'),
 ('subscriptions.manage','Manage school subscription');

INSERT IGNORE INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r JOIN permissions p
WHERE (r.role_key='school_admin')
   OR (r.role_key='department_head' AND p.permission_key IN ('students.view','students.create','students.edit','academics.manage','cards.create'))
   OR (r.role_key='class_teacher' AND p.permission_key IN ('students.view','students.create','students.edit'))
   OR (r.role_key='card_officer' AND p.permission_key IN ('students.view','cards.create','cards.revoke'))
   OR (r.role_key='viewer' AND p.permission_key='students.view');
