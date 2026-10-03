class CreateStoreModels < ActiveRecord::Migration[8.1]
  def change
    create_table :visitors do |t|
      t.string :token, null: false
      t.string :name
      t.string :phone
      t.string :email
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false

      t.timestamps
    end
    add_index :visitors, :token, unique: true

    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: false

      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, [ :published, :position ]
    add_check_constraint :categories, "position >= 0", name: "categories_position_nonnegative"

    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :short_description
      t.integer :price_cents, null: false
      t.integer :old_price_cents
      t.boolean :published, null: false, default: false
      t.boolean :featured, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, [ :published, :featured, :position ]
    add_check_constraint :products, "price_cents >= 0", name: "products_price_cents_nonnegative"
    add_check_constraint :products, "old_price_cents IS NULL OR old_price_cents >= 0", name: "products_old_price_cents_nonnegative"
    add_check_constraint :products, "position >= 0", name: "products_position_nonnegative"

    create_table :carts do |t|
      t.references :visitor, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :carts, :visitor_id, unique: true, where: "status = 0", name: "index_carts_one_active_per_visitor"
    add_index :carts, [ :status, :updated_at ]
    add_check_constraint :carts, "status IN (0, 1, 2)", name: "carts_valid_status"

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true, index: false
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end
    add_index :cart_items, [ :cart_id, :product_id ], unique: true
    add_check_constraint :cart_items, "quantity > 0", name: "cart_items_positive_quantity"

    create_table :orders do |t|
      t.references :visitor, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true, index: false
      t.string :number, null: false
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.text :comment
      t.integer :status, null: false, default: 0
      t.integer :payment_method, null: false, default: 0
      t.integer :payment_status, null: false, default: 0
      t.integer :total_price_cents, null: false

      t.timestamps
    end
    add_index :orders, :number, unique: true
    add_index :orders, :cart_id, unique: true
    add_index :orders, [ :status, :created_at ]
    add_check_constraint :orders, "status IN (0, 1, 2, 3, 4, 5)", name: "orders_valid_status"
    add_check_constraint :orders, "payment_method IN (0, 1, 2)", name: "orders_valid_payment_method"
    add_check_constraint :orders, "payment_status IN (0, 1)", name: "orders_valid_payment_status"
    add_check_constraint :orders, "total_price_cents >= 0", name: "orders_total_price_cents_nonnegative"
    add_check_constraint :orders, "trim(COALESCE(phone, '')) <> '' OR trim(COALESCE(email, '')) <> ''", name: "orders_contact_present"

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_name, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false
      t.integer :total_price_cents, null: false

      t.timestamps
    end
    add_check_constraint :order_items, "unit_price_cents >= 0", name: "order_items_unit_price_cents_nonnegative"
    add_check_constraint :order_items, "quantity > 0", name: "order_items_positive_quantity"
    add_check_constraint :order_items, "total_price_cents >= 0", name: "order_items_total_price_cents_nonnegative"

    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.boolean :published, null: false, default: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, [ :published, :published_at ]

    create_table :inquiries do |t|
      t.references :visitor, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.text :message, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :inquiries, [ :status, :created_at ]
    add_check_constraint :inquiries, "status IN (0, 1, 2, 3)", name: "inquiries_valid_status"
    add_check_constraint :inquiries, "trim(COALESCE(phone, '')) <> '' OR trim(COALESCE(email, '')) <> ''", name: "inquiries_contact_present"
  end
end
