#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [One Q-learning update])[#flow([*Observe*

State, action, reward and next state], [*Target*

Reward plus discounted best next-state value], [*Update*

Move Q toward target; no future reward at terminal])]
