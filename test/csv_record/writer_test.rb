require 'minitest/spec'
require 'minitest/autorun'
require 'csv'

require_relative '../models/car'

describe CsvRecord::Writer do
  describe 'initializing class methods' do
    it 'responds to create' do
      Car.must_respond_to :create
    end
  end

  describe 'initializing instance methods' do
    it ('responds to save') { Car.new.must_respond_to :save }
    it ('responds to new_record?') { Car.new.must_respond_to :new_record? }
    it ('responds to calculate_id') { Car.new.must_respond_to :calculate_id }
    it ('responds to write_object') { Car.new.must_respond_to :write_object }
  end

  describe 'validating the methods behavior' do
    after :each do
      FileUtils.rm_rf 'db'
    end

    let(:car) do
      Car.new(
        year: 1997,
        make: 'Ford',
        model: 'E350',
        description: 'ac, abs, moon',
        price: 3000.00
      )
    end

    let(:second_car) do
      Car.new(
        year: 2007,
        make: 'Chevrolet',
        model: 'F450',
        description: 'ac, abs, moon',
        price: 5000.00
      )
    end

    it "Creates more than one registry" do
      car.save
      second_car.save
      CSV.open(Car::DATABASE_LOCATION, 'r', :headers => true) do |csv|
        csv.entries.size.must_equal 2
      end
    end

    it "Checks whether is a new record" do
      car.new_record?.must_equal true
      car.save
      car.new_record?.must_equal false
    end

    it "Creates the object through create method" do
      created_car = Car.create(
        year: 2007,
        make: 'Chevrolet',
        model: 'F450',
        description: 'ac, abs, moon',
        price: 5000.00
      )
      created_car.wont_be_nil
      created_car.must_be_instance_of Car
      created_car.new_record?.must_equal false
    end

    it "Sets the ID of the created object" do
      car.id.must_be_nil
      car.save
      car.id.must_equal 1
      second_car.save
      second_car.id.must_equal 2
    end
  end
end