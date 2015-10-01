json.array!(@tasks) do |task|
  json.extract! task, :name, :id
end