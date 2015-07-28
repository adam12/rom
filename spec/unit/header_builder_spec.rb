RSpec.describe 'header builder', '#call' do
  subject(:builder) { ROM::Repository::HeaderBuilder.new }

  let(:user_struct) { builder.struct_builder[:users, [:id, :name]] }
  let(:task_struct) { builder.struct_builder[:tasks, [:user_id, :title]] }
  let(:tag_struct) { builder.struct_builder[:tags, [:user_id, :tag]] }

  describe 'with a relation' do
    let(:relation) { double(to_ast: [:relation, :users, [:id, :name]]) }

    it 'produces a valid header' do
      header = ROM::Header.coerce([[:id], [:name]], model: user_struct)

      expect(builder[relation]).to eql(header)
    end
  end

  describe 'with a graph' do
    let(:relation) do
      double(
        to_ast: [
          :graph,
          [:relation, :users, [:id, :name]],
          [
            [:relation, :tasks, [:user_id, :title]],
            [:relation, :tags, [:user_id, :tag]]
          ]
        ]
      )
    end

    it 'produces a valid header' do
      attributes = [
        [:id],
        [:name],
        [:tasks, combine: true, type: :array, keys: { id: :user_id },
         header: ROM::Header.coerce([[:user_id], [:title]], model: task_struct)],
        [:tags, combine: true, type: :array, keys: { id: :user_id },
         header: ROM::Header.coerce([[:user_id], [:tag]], model: tag_struct)]
      ]

      header = ROM::Header.coerce(
        attributes,
        model: builder.struct_builder[:users, [:id, :name, :tasks, :tags]]
      )

      expect(builder[relation]).to eql(header)
    end
  end
end
