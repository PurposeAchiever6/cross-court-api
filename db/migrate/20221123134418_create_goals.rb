class CreateGoals < ActiveRecord::Migration[6.0]
  def up
    create_table :goals do |t|
      t.integer :category, null: false
      t.string :description, null: false
      t.timestamps
    end

    # Initial records to create
    Goal.create(
      category: 'mental',
      description: 'Improve confidence, teamwork, leadership, handling failure, and work on other life skills that allow me to become a better version of myself'
    )
    Goal.create(
      category: 'mental',
      description: 'Enjoy the vibes and feel good'
    )
    Goal.create(
      category: 'mental',
      description: 'Escape from the real world. Basketball is my therapy. Crosscourt is my sanctuary'
    )
    Goal.create(
      category: 'social',
      description: 'Network for business'
    )
    Goal.create(
      category: 'social',
      description: 'Form relationships'
    )
    Goal.create(
      category: 'social',
      description: 'Be a part of a broader community of like minded people'
    )
    Goal.create(
      category: 'physical',
      description: 'Get better at basketball'
    )
    Goal.create(
      category: 'physical',
      description: 'Engage in competitive basketball'
    )
    Goal.create(
      category: 'physical',
      description: 'Improve physical fitness'
    )
    Goal.create(
      category: 'physical',
      description: 'Get a fun, cardio centric, sport fueled sweat'
    )
  end

  def down
    drop_table :goals
  end
end
