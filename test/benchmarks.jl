using POMDPs
using MCTS
using POMDPModels

function POMDPs.simulate(mdp::POMDP,
                  policy::Policy,
                  initial_state::Any,
                  rng::AbstractRNG=MersenneTwister(rand(Uint32)),
                  eps::Float64=0.0)

    disc = 1.0
    r = 0.0
    s = deepcopy(initial_state)

    trans_dist = create_transition_distribution(mdp)

    while disc > eps && !isterminal(mdp, s)

        a = action(policy, s)
         println("$r, $s, $a")
        r += disc*reward(mdp, s, a)

        transition!(trans_dist, mdp, s, a)
        rand!(rng, s, trans_dist)

        disc*=discount(mdp)
    end

    return r
end

##############################


function run_batch(n::Int64,
                   mdp::POMDP,
                   policy::Policy,
                   initial_state::Any;
                   rng=MersenneTwister(rand(Uint32)),
                   eps=0.0)
    rewards = zeros(n)
    for i = 1:n
        rewards[i] = simulate(mdp, policy, initial_state, rng, eps)
    end
    return mean(rewards)
end


##############################

mdp = GridWorld(10,10)
rewards = zeros(20, 9)
initial_state = GridWorldState(1,1)
n=100

for (i,d) in enumerate(1:20), (j,ec) in enumerate(0.0:0.5:4.0)
  println("On: $d, $ec, $i, $j")
  mcts = MCTSSolver(depth=d, exploration_constant=ec)
  policy = MCTSPolicy(mcts, mdp)
  rewards[i,j] = run_batch(n, mdp, policy, initial_state,eps=0.6)
end