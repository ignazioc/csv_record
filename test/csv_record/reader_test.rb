require_relative '../test_helper'

describe CsvRecord::Reader do
  describe 'initializing class methods' do
    it ('responds to fields') { Jedi.must_respond_to :fields }
    it ('responds to all') { Jedi.must_respond_to :all }
  end

  describe 'initializing instance methods' do
    let (:klass) { Jedi.new }

    it ('responds to values') { klass.must_respond_to :values }
    it ('responds to attributes') { klass.must_respond_to :attributes }
    it ('responds to to_param') { klass.must_respond_to :to_param }
    it ('responds to ==') { klass.must_respond_to :== }
    it ('responds to !=') { klass.must_respond_to :!= }
  end

  describe '#build' do
    it 'traditionally' do
      new_jedi = Jedi.build(
        name: 'Yoda the red',
        age: 148,
        midi_chlorians: '0.5k'
      )
      new_jedi.wont_be_nil
      new_jedi.must_be_instance_of Jedi
    end

    it 'with a block' do
      new_jedi = Jedi.build do |jedi|
        jedi.name = 'Yoda the red',
        jedi.age = 148,
        jedi.midi_chlorians = '0.5k'
      end
      new_jedi.wont_be_nil
      new_jedi.must_be_instance_of Jedi
    end
  end

  it '.fields' do
    [:id, :created_at, :updated_at, :name, :age, :midi_chlorians, "jedi_order_id"].each do |field|
      Jedi.fields.must_include field
    end
  end

  it '.values' do
    luke.values.must_equal [nil, nil, nil, "Luke Skywalker", 18, "12k", 0]
  end

  describe 'retrieving resources' do
    before { luke.save }

    it "Retrieves all registries" do
      Jedi.all.size.must_equal 1
      yoda.save
      Jedi.all.size.must_equal 2
    end

    it "counting the registries" do
      Jedi.count.must_equal 1
      yoda.save
      Jedi.count.must_equal 2
    end

    it 'checking to_param' do
      luke.to_param.wont_be_nil
      luke.to_param.must_equal '1'
    end
  end

  describe '==' do
    before do
      yoda.save
      luke.save
      jedi_council.save
    end

    it 'comparing with the same registry' do
      (yoda == yoda).must_equal true
    end

    it 'comparing with a diferent registry' do
      (yoda == luke).must_equal false
    end

    it 'comparing with another class registry' do
      (yoda == jedi_council).must_equal false
    end
  end

  describe '!=' do
    before do
      yoda.save
      luke.save
      jedi_council.save
    end

    it 'comparing with the same registry' do
      (yoda != yoda).must_equal false
    end

    it 'comparing with a diferent registry' do
      (yoda != luke).must_equal true
    end

    it 'comparing with another class registry' do
      (yoda != jedi_council).must_equal true
    end
  end

  describe 'simple query' do
    let (:jedis) { [] }

    before do
      3.times do
        jedis << luke.clone
        jedis.last.save
      end
    end

    it 'querying by id' do
      Jedi.find(jedis.first.id).wont_be_nil
      Jedi.find(jedis.first.id).must_be_instance_of Jedi
    end

    it 'querying by object' do
      Jedi.find(jedis.first).wont_be_nil
      Jedi.find(jedis.first.id).must_be_instance_of Jedi
    end

    it 'gets the first' do
      first_jedi = Jedi.first
      first_jedi.wont_be_nil
      first_jedi.must_be_instance_of Jedi
    end

    it 'gets the last' do
      last_jedi = Jedi.last
      last_jedi.wont_be_nil
      last_jedi.must_be_instance_of Jedi
    end
  end

  describe 'complex queries' do
    before do
      luke.save
      qui_gon_jinn.save
    end

    it 'with a single parameter' do
      result = Jedi.where age: 37
      result.wont_be_empty
      result.first.age.must_equal '37'
    end

    it 'with multiple parameters' do
      result = Jedi.where age: 37, name: 'Qui-Gon Jinn', midi_chlorians: '3k'
      result.wont_be_empty
      result.first.age.must_equal '37'
    end

    it 'with invalid parameter' do
      result = Jedi.where age: 22, name: 'Obi Wan Kenobi'
      result.must_be_empty
    end
  end

  describe 'dynamic finders' do
    before do
      luke.save
      yoda.save
    end

    let (:properties) { Jedi.fields }

    it 'respond to certain dynamic methods' do
      Jedi.must_respond_to "find_by_#{properties.sample}"
    end

    it 'finding with a single field' do
      found_jedi = Jedi.find_by_age(852)
      found_jedi.wont_be_nil
      found_jedi.must_be_instance_of Jedi
    end

    it 'finding with multiple fields' do
      conditions = []
      properties.each_with_index do |property, i|
        values = []
        i.times do |k|
          conditions[i] = conditions[i] ? "#{conditions[i]}_and_#{properties[k]}" : properties[k]
          values << luke.send(properties[k].name)
        end
        if conditions[i]
          found_jedis = Jedi.public_send "find_by_#{conditions[i]}", *values
          found_jedis.wont_be_nil
          found_jedis.must_be_instance_of Jedi
        end
      end
    end
  end
end
