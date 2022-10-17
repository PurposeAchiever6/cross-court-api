module SessionGuests
  class Add
    include Interactor::Organizer

    organize SessionGuests::Validations,
             SessionGuests::Create
  end
end
