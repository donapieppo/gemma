# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "arch_ddts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "number"
    t.string "gen"
    t.string "name"
    t.date "date"
    t.integer "organization_id"
    t.integer "supplier_id"
    t.integer "oldid", null: false
    t.index ["organization_id"], name: "organization_id"
    t.index ["supplier_id"], name: "supplier_id"
  end

  create_table "arch_divisions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "name"
    t.string "description"
    t.string "email"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "arch_operations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "upn", limit: 150
    t.integer "user_id"
    t.string "recipient"
    t.integer "recipient_id"
    t.integer "thing_id"
    t.integer "number"
    t.date "date"
    t.string "ip"
    t.integer "ddt_id"
    t.text "note"
    t.string "type", limit: 100
    t.integer "ycia"
    t.string "ncia", limit: 20
    t.integer "organization_id"
    t.integer "price"
    t.integer "division_id"
    t.integer "oldid", null: false
    t.index ["ddt_id"], name: "index_operations_on_ddt_id"
    t.index ["division_id"], name: "index_operations_on_division_id"
    t.index ["organization_id"], name: "index_operations_on_organization_id"
    t.index ["recipient"], name: "index_operations_on_recipient", length: 191
    t.index ["recipient_id"], name: "recipientid"
    t.index ["thing_id"], name: "index_operations_on_thing_id"
    t.index ["upn"], name: "index_operations_on_upn"
    t.index ["user_id"], name: "userid"
  end

  create_table "arch_things", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "organization_id", null: false
    t.integer "year", null: false
    t.integer "oldid", null: false
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "barcodes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "thing_id"
    t.integer "organization_id"
    t.index ["name"], name: "index_barcodes_on_barcode"
    t.index ["organization_id"], name: "organization_id"
    t.index ["thing_id"], name: "index_barcodes_on_thing_id"
  end

  create_table "ddts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "number"
    t.integer "organization_id"
    t.string "gen"
    t.integer "supplier_id"
    t.string "name"
    t.date "date"
  end

  create_table "delegations", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "delegator_id", null: false, unsigned: true
    t.integer "delegate_id", null: false, unsigned: true
    t.integer "organization_id", null: false
    t.index ["delegate_id"], name: "delegate_id"
    t.index ["delegator_id"], name: "delegator_id"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "deposits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "thing_id"
    t.integer "actual"
    t.integer "location_id"
    t.integer "organization_id"
    t.index ["location_id"], name: "location_id"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
  end

  create_table "images", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "thing_id", null: false, unsigned: true
    t.integer "user_id", unsigned: true
    t.datetime "created_at"
    t.string "photo_file_name", limit: 200
    t.string "photo_content_type", limit: 100
    t.integer "photo_file_size", unsigned: true
    t.datetime "photo_updated_at"
    t.index ["user_id"], name: "userid"
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.index ["organization_id"], name: "index_locations_on_organization_id"
  end

  create_table "moves", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "number", null: false
    t.integer "deposit_id", null: false
    t.integer "operation_id", null: false
    t.index ["deposit_id"], name: "index_moves_on_deposit_id"
    t.index ["operation_id"], name: "index_moves_on_operation_id"
  end

  create_table "networks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.integer "authlevel"
  end

  create_table "notices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "organization_id"
    t.string "notice"
  end

  create_table "operations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "thing_id", null: false
    t.integer "number", null: false
    t.integer "user_id"
    t.integer "recipient_id"
    t.date "date"
    t.integer "ddt_id"
    t.text "note"
    t.integer "ycia"
    t.string "ncia", limit: 200
    t.string "type", limit: 100, null: false
    t.integer "price"
    t.text "price_operations"
    t.integer "division_id"
    t.boolean "from_booking"
    t.index ["date"], name: "date_idx"
    t.index ["ddt_id"], name: "index_operations_on_ddt_id"
    t.index ["organization_id"], name: "organization_id"
    t.index ["recipient_id"], name: "recipientid"
    t.index ["thing_id"], name: "index_operations_on_thing_id"
    t.index ["user_id"], name: "userid"
  end

  create_table "orderingcalendars", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "group_id", null: false
    t.date "from", null: false
    t.date "until", null: false
    t.index ["group_id"], name: "index_orderingcalendars_on_group_id"
  end

  create_table "orders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.integer "thing_id", null: false
    t.integer "number", null: false
    t.integer "organization_id", null: false
    t.integer "division_id"
    t.date "date", null: false
    t.string "note"
    t.index ["organization_id"], name: "index_orders_on_organization_id"
    t.index ["thing_id"], name: "index_orders_on_thing_id"
    t.index ["user_id"], name: "userid"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "sendmail", limit: 1
    t.string "adminmail", limit: 200
    t.boolean "booking"
    t.boolean "ordering"
    t.boolean "pricing"
    t.boolean "division"
  end

  create_table "permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "user_id", unsigned: true
    t.integer "organization_id"
    t.string "network", limit: 20
    t.integer "authlevel"
    t.index ["organization_id"], name: "fk_organization_permission"
    t.index ["user_id"], name: "fk_user_permission"
  end

  create_table "schema_info", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "version"
  end

  create_table "suppliers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "pi"
  end

  create_table "things", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "group_id"
    t.integer "minimum"
    t.integer "total", default: 0, unsigned: true
    t.integer "organization_id"
    t.text "future_prices"
    t.index ["group_id"], name: "group_id"
    t.index ["organization_id"], name: "organization_id"
  end

  create_table "users", id: :integer, unsigned: true, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "upn", limit: 150
    t.string "gender", limit: 1
    t.string "name", limit: 50
    t.string "surname", limit: 50
    t.string "email"
    t.integer "emplyeeid"
    t.timestamp "updated_at", default: -> { "current_timestamp()" }, null: false
    t.index ["upn"], name: "index_dsacaches_on_upn", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
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
  add_foreign_key "delegations", "organizations", name: "delegations_ibfk_3"
  add_foreign_key "delegations", "users", column: "delegate_id", name: "delegations_ibfk_2"
  add_foreign_key "delegations", "users", column: "delegator_id", name: "delegations_ibfk_1"
  add_foreign_key "deposits", "locations", name: "deposits_ibfk_1"
  add_foreign_key "deposits", "organizations", name: "deposits_ibfk_2"
  add_foreign_key "moves", "deposits", name: "moves_ibfk_2"
  add_foreign_key "moves", "operations", name: "moves_ibfk_1"
  add_foreign_key "operations", "ddts", name: "operations_ibfk_2"
  add_foreign_key "operations", "organizations", name: "operations_ibfk_3"
  add_foreign_key "operations", "things", name: "operations_ibfk_1"
  add_foreign_key "orders", "organizations", name: "orders_ibfk_2"
  add_foreign_key "orders", "things", name: "orders_ibfk_1"
  add_foreign_key "permissions", "organizations", name: "fk_organization_permission"
  add_foreign_key "permissions", "users", name: "fk_user_permission"
  add_foreign_key "things", "groups", name: "things_ibfk_2"
  add_foreign_key "things", "organizations", name: "things_ibfk_1"
end
