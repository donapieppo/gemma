# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2022_05_25_142402) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "arch_ddts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "date"
    t.string "gen"
    t.string "name"
    t.integer "number"
    t.integer "oldid", null: false
    t.integer "organization_id"
    t.integer "supplier_id"
    t.index ["organization_id"], name: "organization_id"
    t.index ["supplier_id"], name: "supplier_id"
  end

  create_table "arch_divisions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "description"
    t.string "email"
    t.string "name"
    t.integer "organization_id", null: false
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "arch_operations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "date"
    t.integer "ddt_id"
    t.integer "division_id"
    t.string "ip"
    t.string "ncia", limit: 20
    t.text "note"
    t.integer "number"
    t.integer "oldid", null: false
    t.integer "organization_id"
    t.integer "price"
    t.string "recipient"
    t.integer "recipient_id"
    t.integer "thing_id"
    t.string "type", limit: 100
    t.string "upn", limit: 150
    t.integer "user_id"
    t.integer "ycia"
    t.index ["ddt_id"], name: "index_operations_on_ddt_id"
    t.index ["division_id"], name: "index_operations_on_division_id"
    t.index ["organization_id"], name: "index_operations_on_organization_id"
    t.index ["recipient"], name: "index_operations_on_recipient", length: 191
    t.index ["recipient_id"], name: "recipientid"
    t.index ["thing_id"], name: "index_operations_on_thing_id"
    t.index ["upn"], name: "index_operations_on_upn"
    t.index ["user_id"], name: "userid"
  end

  create_table "arch_things", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "description"
    t.string "name"
    t.integer "oldid", null: false
    t.integer "organization_id", null: false
    t.integer "year", null: false
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "barcodes", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.integer "thing_id"
    t.index ["name"], name: "index_barcodes_on_barcode"
    t.index ["organization_id"], name: "organization_id"
    t.index ["thing_id"], name: "index_barcodes_on_thing_id"
  end

  create_table "cost_centers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "description"
    t.string "name", limit: 200, null: false
    t.integer "organization_id", null: false
    t.index ["organization_id"], name: "fk_cost_center_organizations"
  end

  create_table "ddts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "date"
    t.string "gen"
    t.string "name"
    t.integer "number"
    t.integer "organization_id"
    t.integer "supplier_id"
  end

  create_table "delegations", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "cost_center_id"
    t.integer "delegate_id", null: false, unsigned: true
    t.integer "delegator_id", null: false, unsigned: true
    t.integer "organization_id", null: false
    t.integer "picking_point_id"
    t.index ["cost_center_id"], name: "fk_delegation_cost_center"
    t.index ["delegate_id"], name: "delegate_id"
    t.index ["delegator_id"], name: "delegator_id"
    t.index ["organization_id"], name: "organization_id"
    t.index ["picking_point_id"], name: "fk_delegation_picking_point"
  end

  create_table "deposits", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "actual"
    t.integer "location_id"
    t.integer "organization_id"
    t.integer "thing_id"
    t.index ["location_id"], name: "location_id"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
  end

  create_table "images", id: { type: :integer, unsigned: true }, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "thing_id", null: false, unsigned: true
    t.integer "user_id", unsigned: true
    t.index ["user_id"], name: "userid"
  end

  create_table "labs", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.index ["organization_id"], name: "fk_labs_organizations"
  end

  create_table "locations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.index ["organization_id"], name: "index_locations_on_organization_id"
  end

  create_table "moves", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "deposit_id", null: false
    t.integer "number", null: false
    t.integer "operation_id", null: false
    t.index ["deposit_id"], name: "index_moves_on_deposit_id"
    t.index ["operation_id"], name: "index_moves_on_operation_id"
  end

  create_table "notices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "notice"
    t.integer "organization_id"
  end

  create_table "operations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "cost_center_id"
    t.datetime "created_at", precision: nil
    t.date "date"
    t.integer "ddt_id"
    t.boolean "from_booking"
    t.integer "lab_id", unsigned: true
    t.string "ncia", limit: 200
    t.text "note"
    t.integer "number", null: false
    t.integer "organization_id", null: false
    t.integer "picking_point_id"
    t.integer "price"
    t.text "price_operations"
    t.integer "recipient_id"
    t.integer "thing_id", null: false
    t.string "type", limit: 100, null: false
    t.integer "user_id"
    t.integer "ycia"
    t.index ["cost_center_id"], name: "fk_operation_cost_center"
    t.index ["ddt_id"], name: "index_operations_on_ddt_id"
    t.index ["lab_id"], name: "operations_labfk"
    t.index ["organization_id"], name: "organization_id"
    t.index ["picking_point_id"], name: "fk_operation_picking_point"
    t.index ["recipient_id", "organization_id"], name: "operation_recipient_organization_index"
    t.index ["recipient_id"], name: "recipientid"
    t.index ["thing_id"], name: "index_operations_on_thing_id"
    t.index ["user_id", "organization_id"], name: "operation_user_organization_index"
    t.index ["user_id"], name: "userid"
  end

  create_table "orderingcalendars", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", options: "ENGINE=MyISAM", force: :cascade do |t|
    t.date "from", null: false
    t.integer "group_id", null: false
    t.date "until", null: false
    t.index ["group_id"], name: "index_orderingcalendars_on_group_id"
  end

  create_table "orders", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "date", null: false
    t.integer "division_id"
    t.string "note"
    t.integer "number", null: false
    t.integer "organization_id", null: false
    t.integer "thing_id", null: false
    t.integer "user_id"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["thing_id"], name: "index_orders_on_thing_id"
    t.index ["user_id"], name: "userid"
  end

  create_table "organizations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "adminmail", limit: 200
    t.boolean "booking"
    t.string "code"
    t.datetime "created_at", precision: nil
    t.string "description"
    t.string "name"
    t.boolean "ordering"
    t.boolean "pricing"
    t.string "sendmail", limit: 1
    t.datetime "updated_at", precision: nil
  end

  create_table "permissions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "authlevel"
    t.datetime "created_at", precision: nil
    t.string "network", limit: 20
    t.integer "organization_id"
    t.datetime "updated_at", precision: nil
    t.integer "user_id", unsigned: true
    t.index ["organization_id"], name: "fk_organization_permission"
    t.index ["user_id"], name: "fk_user_permission"
  end

  create_table "picking_points", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "description"
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.index ["organization_id"], name: "fk_picking_points_organizations"
  end

  create_table "schema_info", id: false, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "version"
  end

  create_table "suppliers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "pi"
  end

  create_table "things", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "description"
    t.text "dewars"
    t.text "future_prices"
    t.integer "group_id"
    t.integer "minimum"
    t.string "name"
    t.integer "organization_id"
    t.integer "total", default: 0, unsigned: true
    t.index ["group_id"], name: "group_id"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "users", id: { type: :integer, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "email"
    t.integer "emplyeeid"
    t.string "gender", limit: 1
    t.string "name", limit: 50
    t.string "surname", limit: 50
    t.timestamp "updated_at", default: -> { "current_timestamp() ON UPDATE current_timestamp()" }, null: false
    t.string "upn", limit: 150
    t.index ["upn"], name: "index_dsacaches_on_upn", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "arch_ddts", "organizations", name: "arch_ddts_ibfk_1"
  add_foreign_key "arch_ddts", "suppliers", name: "arch_ddts_ibfk_2"
  add_foreign_key "arch_divisions", "organizations", name: "arch_divisions_ibfk_1"
  add_foreign_key "arch_operations", "arch_ddts", column: "ddt_id", name: "arch_operations_ibfk_3"
  add_foreign_key "arch_operations", "arch_divisions", column: "division_id", name: "arch_operations_ibfk_4"
  add_foreign_key "arch_operations", "arch_things", column: "thing_id", name: "arch_operations_ibfk_2"
  add_foreign_key "arch_operations", "organizations", name: "arch_operations_ibfk_1"
  add_foreign_key "arch_things", "organizations", name: "arch_things_ibfk_1"
  add_foreign_key "barcodes", "organizations", name: "barcodes_ibfk_2"
  add_foreign_key "barcodes", "things", name: "barcodes_ibfk_1"
  add_foreign_key "cost_centers", "organizations", name: "fk_cost_center_organizations"
  add_foreign_key "delegations", "cost_centers", name: "fk_delegation_cost_center", on_update: :cascade, on_delete: :nullify
  add_foreign_key "delegations", "organizations", name: "delegations_ibfk_3"
  add_foreign_key "delegations", "picking_points", name: "fk_delegation_picking_point", on_update: :cascade, on_delete: :nullify
  add_foreign_key "delegations", "users", column: "delegate_id", name: "delegations_ibfk_2"
  add_foreign_key "delegations", "users", column: "delegator_id", name: "delegations_ibfk_1"
  add_foreign_key "deposits", "locations", name: "deposits_ibfk_1"
  add_foreign_key "deposits", "organizations", name: "deposits_ibfk_2"
  add_foreign_key "labs", "organizations", name: "fk_labs_organizations"
  add_foreign_key "moves", "deposits", name: "moves_ibfk_2"
  add_foreign_key "moves", "operations", name: "moves_ibfk_1"
  add_foreign_key "operations", "cost_centers", name: "fk_operation_cost_center", on_update: :cascade, on_delete: :nullify
  add_foreign_key "operations", "ddts", name: "operations_ibfk_2"
  add_foreign_key "operations", "labs", name: "operations_labfk"
  add_foreign_key "operations", "organizations", name: "operations_ibfk_3"
  add_foreign_key "operations", "picking_points", name: "fk_operation_picking_point", on_update: :cascade, on_delete: :nullify
  add_foreign_key "operations", "things", name: "operations_ibfk_1"
  add_foreign_key "orders", "organizations", name: "orders_ibfk_2"
  add_foreign_key "orders", "things", name: "orders_ibfk_1"
  add_foreign_key "permissions", "organizations", name: "fk_organization_permission"
  add_foreign_key "permissions", "users", name: "fk_user_permission"
  add_foreign_key "picking_points", "organizations", name: "fk_picking_points_organizations"
  add_foreign_key "things", "groups", name: "things_ibfk_2"
  add_foreign_key "things", "organizations", name: "things_ibfk_1"
end
