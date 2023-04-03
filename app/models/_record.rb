# frozen_string_literal: true

class Record
  class << self
    def all
      query = <<~SQL.chomp
        SELECT * FROM #{table_name}
      SQL

      DB.execute(query).map do |record_attributes|
        new(record_attributes.transform_keys(&:to_sym))
      end
    end

    def find(id)
      query = <<~SQL.chomp
        SELECT * FROM #{table_name} WHERE id=?
      SQL

      record_attributes = DB.execute(query, id).first
      return unless record_attributes

      new(record_attributes.transform_keys(&:to_sym))
    end

    def where(attributes)
      query = <<~SQL.chomp
        SELECT * FROM #{table_name} WHERE #{attributes.keys.join('=?,')}=?
      SQL

      DB.execute(query, *attributes.values).map do |record_attributes|
        new(record_attributes.transform_keys(&:to_sym))
      end
    end

    def create(attributes)
      new(attributes).save
    end

    private

    def table_name
      "#{to_s.downcase}s"
    end
  end

  attr_reader :id, :created_at

  def initialize(attributes)
    @id = attributes[:id]
    @created_at = Time.parse(attributes[:created_at]) if attributes[:created_at]
  end

  def save
    id ? update : create
  end

  def create
    query = <<~SQL.chomp
      INSERT INTO #{self.class}s (#{attributes.join(',')}, created_at)
      VALUES (#{Array.new(attributes.size, '?').join(',')}, ?)
    SQL

    @created_at = Time.now.utc
    DB.execute(query, *attributes.map { |attr| public_send(attr) }, created_at.to_s)
    @id = DB.last_insert_row_id
    self
  end

  def update
  end
end
