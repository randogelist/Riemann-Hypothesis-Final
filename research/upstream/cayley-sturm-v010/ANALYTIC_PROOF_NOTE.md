# Unconditional mathematical argument to port: matched off-line channel

Use the actual genus-zero product of Theta(z)=xi(1/2+sqrt z) and write its negative spectral scales as
lambda_rho=(gamma-i beta)^2, rho=1/2+beta+i gamma, gamma>0.
The correctly normalized central Widder coefficient is

W_n(a)=sum_rho multiplicity(rho)*(4 a lambda_rho/(a+lambda_rho)^2)^(n+1),

with the actual zeros counted in the convention of the SOLOBOLO source.

Let L=beta^2+gamma^2=|lambda_rho|. Exact algebra:

|a+lambda_rho|^2 = (a-L)^2+4a gamma^2,
|4a lambda_rho/(a+lambda_rho)^2|=4aL/((a-L)^2+4a gamma^2)
  <= L/gamma^2 = 1+(beta/gamma)^2.

At a=L the Cayley factor itself (not only its norm) equals L/gamma^2>1 when beta !=0.

If not-RH, pick a zero maximizing r=|beta/gamma|>0. This is attained because
|beta|<=1/2, zero ordinates are bounded away from 0, and zeros form a discrete
set; competitors with ratio >= fixed positive r have bounded height.
Fix its matched anchor a*=L and Q=1+r^2>1. All factors have modulus <=Q.
Those with modulus Q are precisely the finitely many matched extreme modes;
all their q-values are the positive real number Q. Others have a strict modulus
gap eta<Q by local finiteness and the genus-zero summable tail.

With a summable first-power envelope,
  W_n(a*) = A*Q^(n+1) + O(eta^n), A>0,
so sup_n W_n(a*)=infinity. This is precisely the explicit
`OFFLINE_WIDDER_EXPLOSION_FRONTIER` in the new endpoint.

Lean work remaining: complete native Mathlib xi product normalization and zero
multiplicity transfer; formalize the maximum/gap/tail argument for the *actual*
`actualCentralWidder`. The finite modulus and matched-radius estimates are
separate, newly authored Lean statements in `MatchedAmplification.lean`.

Independently, show finite witness checker -> actual all-anchor trace
calibration. The source presently proves only finite trace bounds; no general
actual-xi calibration is claimed.
