from scipy.stats import beta
from scipy.special import betaln
import numpy as np


# based upon https://www.evanmiller.org/bayesian-ab-testing.html#binary_ab_implementation
def prob_B_beats_A(alpha_A, beta_A, alpha_B, beta_B):
    total = 0
    for i in range(0, alpha_B - 1):
        total += np.exp(betaln(alpha_A + i, beta_B + beta_A) - \
                        np.log(beta_B + i) - betaln(1 + i, beta_B) - betaln(alpha_A, beta_A))
    return total


# Don’t forget to add 1 to the success and failure counts! Otherwise your results will be slightly off.

alpha_A = 1 + (conversions_A)
beta_A = 1 + (users_A - conversions_A)
alpha_B = 1 + (conversions_B)
beta_B = 1 + (users_B - conversions_B)

p_test_is_winner = prob_B_beats_A(alpha_A, beta_A, alpha_B, beta_B)
print("Probability that B beats A is: {:2.2f}%".format(100 * p_test_is_winner))