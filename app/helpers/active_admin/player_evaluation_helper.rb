module ActiveAdmin
  module PlayerEvaluationHelper
    def player_evaluation_data
      [
        {
          title: 'Ball Handling',
          key: 'ball-handling',
          options: [
            {
              content: 'Has difficulty dribbling and catching',
              score: '2'
            },
            {
              content: 'Possesses some ball handling skills but they are very limited',
              score: '3'
            },
            {
              content: 'Can handle ball with dominant hand only',
              score: '4'
            },
            {
              content: 'Can handle ball with both hands',
              score: '5'
            },
            {
              content: 'Has ability to go either direction on the dribble',
              score: '6'
            },
            {
              content: 'Has ability to beat defender regularly with dominant hand',
              score: '7'
            },
            {
              content: 'Has ability to beat defender regularly with either hand',
              score: '8'
            }
          ]
        },
        {
          title: 'Passing',
          key: 'passing',
          options: [
            {
              content: 'Has difficulty completing a pass / short pass to a teammate',
              score: '2'
            },
            {
              content: 'Can sometimes make a pass to an open teammate with token pressure',
              score: '3'
            },
            {
              content: 'Can only complete a pass to teammate after looking directly at him / her',
              score: '4'
            },
            {
              content: 'Has ability to choose best type of pass (bounce, chest, skip, other)',
              score: '5'
            },
            {
              content: 'Has ability to complete a no look or quick pass to an open teammate',
              score: '6'
            },
            {
              content: 'Controls game with ability to complete an advanced pass ' \
                       '(no look / snap pass) to an open player when they are in good position',
              score: '8'
            }
          ]
        },
        {
          title: 'Movement',
          key: 'movement',
          options: [
            {
              content: 'Maintains a stationary position; does not move to a loose ball ',
              score: '2'
            },
            {
              content: 'Moves only 1-2 steps toward ball or opponent',
              score: '3'
            },
            {
              content: 'Moves toward ball; but reaction time is slow and only in a limited area ' \
                       'of the floor',
              score: '4'
            },
            {
              content: 'Movement permits adequate court coverage',
              score: '5'
            },
            {
              content: 'Good court coverage; reasonably aggressive',
              score: '6'
            },
            {
              content: 'Exceptional court coverage; aggressive anticipation',
              score: '8'
            }
          ]
        },
        {
          title: 'Game Awareness',
          key: 'game-awareness',
          options: [
            {
              content: 'Sometimes confused on offense and defense; may shoot at wrong basket',
              score: '2'
            },
            {
              content: 'Can play in fixed position as instructed by coach; may go after an ' \
                       'occasional loose ball',
              score: '3'
            },
            {
              content: 'Limited understanding of the game and can run some offensive and ' \
                       'defensive sets - coach prompted',
              score: '4'
            },
            {
              content: 'Moderate understanding of the game, some off and def sets and can ' \
                       'occasionally fast break',
              score: '6'
            },
            {
              content: 'Advanced understanding of the game and mastery of basketball fundamentals',
              score: '8'
            }
          ]
        },
        {
          title: 'Shooting',
          key: 'shooting',
          options: [
            {
              content: 'Periodically can make an uncontested layup',
              score: '2'
            },
            {
              content: 'Can make shots inside of lane',
              score: '3'
            },
            {
              content: 'Can make shots inside of lane and occasionally attempts a mid range ' \
                       'jump shot',
              score: '4'
            },
            {
              content: 'Can make some mid range jump shots',
              score: '5'
            },
            {
              content: 'Can make some mid range jump shots and will attempt shots beyond 15\'',
              score: '6'
            },
            {
              content: 'Has excellent shooting form and makes shots from all ranges on court',
              score: '8'
            }
          ]
        }
      ]
    end
  end
end
