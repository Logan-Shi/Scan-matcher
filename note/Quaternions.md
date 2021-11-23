# Quaternions

$$
\begin{align*}
q = a+\bold{i}b+\bold{j}c+\bold{k}d,\quad a,b,c,d\in \mathbb{R}
\end{align*}
$$

## Abstract Algebra

### group

a set G with an operation $*$ which satisfies the axioms: 

1. associative

$$
(a*b)*c=a*(b*c)
$$

2. element *zero*

$$
\forall a \in G,\exist e,s.t.a*e=e*a
$$

3. element *inverse*

$$
\forall a, \exist a^{-1},s.t. a*a^{-1}=a^{-1}*a=e
$$

### ring





a set A with operations called addition $+$ and multiplication $*$ which satisfy the following axioms: 

1. A with addition alone is an abelian group
2. Multiplication is associative
3. Multiplication is distributive over addition

#### some terms

**commutative ring** multiplication is also commutative. 

**filed** a commutative ring with unity in which every nonzero element is invertible.

**unity** neutral element for multiplication. 

**division ring** non-commutative ring

# Optimization

least square optimization
$$
\min_{\bold x \in \chi} \sum_{i=1}^{N} r^{2}(\bold y_{i},\bold x)
$$
where $x$ is the variable to estimate, e.g. the pose in ICP problems, 

$\chi$ is the domain of $x$, e.g. $SO(3)$ in ICP problems, 

$\bold y_{i}$ is the $i^{th}$ measurement, 

the function $r(\bold y_{i},\bold x)$ is the residual for the $i^{th}$ measurement. 

Generally $\eqref{eq:op_1}$ is difficult to solve globally, due to the nonlinearity of the residual function and non-convexity of $\chi$. Further more, in the presence of outliers, $\eqref{eq:op_1}$ gives false estimation. This call for a robust cost $\rho(\cdot)$
$$
\min_{\bold x \in \chi} \sum_{i=1}^{N} \rho (r(\bold y_{i},\bold x))
$$

## Graduated non-convexity (GNC)

### Black-Rangarajan duality

Given a robust cost function $\rho(\cdot)$, define $\phi(z):=\rho(\sqrt z)$. If $\phi(z)$ satisfies $\lim_{z\to0}\phi'(z)=1$, $\lim_{z\to \infty}\phi'(z)=0$, and $\phi''(z)<0$, then the robust estimation problem $\eqref{eq:op_2}$ is equivalent to
$$
\min_{\bold x \in \chi,w_i\in [0,1]} \sum_{i=1}^{N} [w_i r^2(\bold y_{i},\bold x)+\Phi_\rho (w_i)] \label{eq:op_3}
$$
where $w_i\in [0,1]$ are weight associated to measurement $y_i$, and the function $\Phi_\rho(w_i)$  defines a penalty on the weight $w_i$, which depends on the choice of robust cost function $\rho(\cdot)$.

### GNC

GNC is a popular approach for the optimization of a generic non-convex cost function $\rho(\cdot)$. 

The basic idea is to introduce a surrogate cost $\rho_\mu(\cdot)$, governed by a control parameter $\mu$, which adjust the non-convexity. 

#### Example 1 (Geman McClure and GNC)

[GM](#GM) as following, blue is original residual, red is residual reduced. Smaller c indicate larger penalty for outliers. Results in slower converge but more robust. 

![GM](/home/logan/.config/Typora/typora-user-images/image-20211116192404354.png)
$$
\rho_\mu(r)=\frac{\mu \bar c^2 r^2}{\mu \bar c^2+r^2}
$$
$$
\lim_{\mu\to\infty}\rho_{\mu}=\rho
$$



the surrogate function $\rho_\mu(r)$ satisfies (i) $\rho_\mu(r)$ becomes convex for large $\mu$. (ii) $\mu=1$ recovers the original form [image](#GNC)

<img src="/home/logan/.config/Typora/typora-user-images/image-20211116170814238.png" alt="GNC" style="zoom:50%;" />

#### Example 2 (TLS)

[TLS](#TLS) is defined as
$$
\rho(r)=\begin{cases} 
      r^2 & if \, r^2\in [0,\bar c^2] \\
      \bar c^2 & if \, r^2 \in [\bar c^2,+ \infty)
   \end{cases}
$$
![TLS](/home/logan/.config/Typora/typora-user-images/image-20211116192913808.png)

GNC surrogate is1
$$
\rho_\mu(r)=\begin{cases} 
      r^2 & if \, r^2\in [0,\frac{\mu}{\mu+1}\bar c^2] \\
      2\bar c \abs{r} \sqrt{\mu(\mu+1)}-\mu(\bar c^2+r^2) & if \, r^2 \in [\frac{\mu}{\mu+1}\bar c^2,\frac{\mu+1}{\mu}\bar c^2]\\
      \bar c^2 & if \,r^2 \in [\bar c^2,+ \infty)
   \end{cases}
$$

### Implementation

#### variable update

For inner loop, first fix $w_i$ and minimize $\eqref{eq:op_3}$ with respect to $\bold x$
$$
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}
\bold x^{(t)} = \argmin_{\bold x \in \chi} \sum_{i=1}^{N} w_i^{(t-1)} r^2(\bold y_{i},\bold x) \label{eq:op_4}
$$
which can be solved globally. 

#### weight update

Then fix $x$ and minimize $\eqref{eq:op_3}$ with respect to $w_i$. 
$$
\bold w^{(t)}=\argmin_{\bold x \in \chi,w_i\in [0,1]} \sum_{i=1}^{N} [w_i r^2(\bold y_{i},\bold x^{(t)})+\Phi_\rho (w_i)] \label{eq:op_6}
$$
we will now try to optimize $\Phi_\rho (w_i)$ in closed form.

#### $\mu$ update

#### GM-GNC

given
$$
\Phi_{\rho_\mu}(w_i)=\mu \bar c^2(\sqrt{w_i}-1)^2
$$
then $\eqref{eq:op_6}$ can be solved in closed form
$$
w_i^{(t)}=\Big(\frac{\mu \bar c^2}{\hat{r}_i^2+\mu \bar c^2}\Big)^2
$$
where $\hat{r}=r(\bold y_i,\bold x^{(t)})$

#### TLS-GNC

$$
\Phi_{\rho_\mu}(w_i)=\frac{\mu (1-w_i)}{\mu+w_i}\bar c^2
$$

closed form as following:
$$
w_i^{(t)}=\begin{cases} 
      0 & if \, \hat{r}^2\in [\frac{\mu+1}{\mu}\bar c^2,+\infty] \\
      \frac{\bar c}{\hat{r}_i}  \sqrt{\mu(\mu+1)}-\mu & if \, r^2 \in [\frac{\mu}{\mu+1}\bar c^2,\frac{\mu+1}{\mu}\bar c^2]\\
      1 & if \,r^2 \in [0,\frac{\mu}{\mu+1}\bar c^2)
   \end{cases}
$$

## Residuals

### notation

$$
\bold b_i\in B \\
\bold a_i\in A
$$

### 基本形式

$$
\bold T=\argmin_{\bold T\in SE(3)}\sum_{i=1}^m\norm{\bold T\otimes \bold a_i-\bold b_i}_2^2
$$

$$
(\bold R,\bold t)=\argmin_{\bold R\in SO(3),\bold t\in \R^3}\sum_{i=1}^m\norm{\bold R \bold a_i+\bold t-\bold b_i}_2^2
$$

$$
\frac{\partial E}{\partial \bold t}=\bold 0
$$

$$
\bold t = \bar{\bold b}-\bold R\bar{\bold a},\quad\bar{\bold a}=\frac{1}{m}\sum_{i=1}^m\bold a_i,\bar{\bold b}=\frac{1}{m}\sum_{i=1}^m\bold b_i
$$

$$
\bold R=\argmin_{\bold R\in SO(3)}\sum_{i=1}^m\norm{\bold R \tilde{\bold a}_i-\tilde{\bold b}_i}_2^2
$$

$$
\tilde{\bold b}_i=\bold b_i-\bar{\bold b},\tilde{\bold a}_i=\bold a_i-\bar{\bold a}
$$

$$
\norm{\bold R \tilde{\bold a}_i-\tilde{\bold b}_i}_2^2=\tilde{\bold a}_i^T\tilde{\bold a}_i-2\tilde{\bold b}_i^T\bold R\tilde{\bold a}_i+\tilde{\bold b}_i^T\tilde{\bold b}_i
$$

$$
\bold S = \bold U\bold \Sigma \bold V^T,\quad \bold R=\bold V\bold U^T
$$

$$
\bold S = \bold X\bold Y^T,\quad\bold X_{i,:}=\tilde{\bold a}_i,\bold Y_{i,:}=\tilde{\bold b}_i
$$

## generalized distance function

$$
r=d_{B}(\bold T*\bold a_i)
$$

$d_B(\cdot)$ denote the  minimum distance to B. 

### generalized form

$$
\begin{align}
d_B(\bold x) & =\min_{\bold b_i\in B}\norm{\bold x-\bold b_i}_{\bold C}\\
       & =(\bold x - \bold b_i)^T*\bold C*(\bold x - \bold b_i)
\end{align}
$$

#### point to point

$$
d_B(\bold x)=\min_{\bold b_i\in B}\norm{\bold x-\bold b_i}_{\bold I}
$$

#### point to line 

$$
d_B(\bold x)=\min_{\bold b_i\in B}\norm{\bold x-\bold b_i}_{(\bold I-\bold v\bold v^T)}
$$

where $v$ is the unit direction vector for a line. 

#### point to plane

$$
d_B(\bold x)=\min_{\bold b_i\in B}\norm{\bold x-\bold b_i}_{(\bold n\bold n^T)}
$$

where $n$ is the unit normal vector for a plane. 

### Gauss-Newton Least square

$$
\bold x=\argmin_\bold x\sum_i\bold r_i(\bold x)^T\bold \Omega_i\bold r_i(\bold x)
$$

$$
E(\bold x)=\sum_i\bold r_i(\bold x)^T\bold \Omega_i\bold r_i(\bold x)
$$

$$
E(\bold x+\Delta \bold x)=\sum_i\bold r_i(\bold x+\Delta \bold x)^T\bold \Omega_i\bold r_i(\bold x+\Delta \bold x)
$$

$$
\bold r_i(\bold x^*+\Delta \bold x)\simeq \underbrace{\bold r_i(\bold x^*)}_{\bold r_i}+\underbrace{\frac{\partial\bold r_i(\bold x)}{\partial(\bold x)}|_{\bold x=\bold x^*}}_{\bold J_i}\Delta\bold x
$$

$$
\bold r_i(\bold x+\Delta \bold x)^T\bold \Omega_i\bold r_i(\bold x+\Delta \bold x)\simeq \Delta\bold x^T\underbrace{\bold J_i^T\bold \Omega_i\bold J_i}_{\bold H_i}\Delta \bold x+2\underbrace{\bold J_i^T\bold \Omega_i \bold r_i}_{\bold b_i^T} \Delta \bold x + \underbrace{\bold r_i^T\bold \Omega_i\bold r_i}_{c_i}
$$

$$
\bold x = \bold x+\Delta \bold x
$$

$$
E(\bold x+\Delta \bold x)\simeq \underbrace{\sum_ic_i}_{c}+2\underbrace{\sum_i\bold b_i^T}_{\bold b^T} \Delta \bold x+\Delta\bold x^T\underbrace{\sum_i\bold H_i}_{\bold H}\Delta \bold x
$$

$$
\Delta \bold x=\argmin_{\Delta \bold x}E(\bold x+\Delta \bold x)
$$

$$
\Delta \bold x\simeq \argmin_{\Delta \bold x} \Delta \bold x^T\bold H\Delta \bold x+2\bold b^T\Delta \bold x+c
$$

$$

$$



## Quadratic formulation

$$
d_B^2(\bold T* \bold a_i)=(\bold T*\bold a_i - \bold b_i)^T*\bold C*(\bold T*\bold a_i - \bold b_i)
$$

$\bold T* \bold a_i$ is in fact linear in the elements of $\bold T$
$$
\bold T* \bold a_i=\bold R\bold a_i+\bold t=\underbrace{(\bold{\tilde a}_i\,\otimes\,\bold I_3)}_{\bold A_i}vec(\bold T)
$$
where $\tilde{\bold a}_i=[\bold a_i^T,1]^T$, $vec(T)=\begin{bmatrix}vec(\bold R)\\\bold t\end{bmatrix}$. 

we name $\tau=vec(\bold T)$, the generalized distance is a quadratic function of $\tau$
$$
d_B^2(\bold T* \bold a_i)=\tilde \tau^T\underbrace{\bold N_i^T\bold C_i\bold N_i}_{\tilde {\bold M}_i}\tilde \tau
$$
with $\bold N_i=[\tilde {\bold a}_i\,\otimes\,\bold I_3|-\bold b_i]$ and $\tilde \tau=\begin{bmatrix} vec(\bold T\\1\end{bmatrix}^T$. 

compression for the whole point cloud
$$
f(\bold T)=\sum^m_{i=1}d^2_{B_i}(\bold T\,\otimes\,\bold a_i)=\tilde{\bold \tau}^T\underbrace{\Bigg( \sum^m_{i=1}\tilde{\bold M}_i\Bigg)}_{\tilde{\bold M}}\tilde {\bold{\tau}}
$$
$\bold t$ can be derived in terms of $\bold R$
$$
\bold t(\bold R)=-\tilde{\bold M}_{\bold t,\bold t}^{-1}\tilde{\bold M}_{\bold t,\bold !t}\tilde{\bold r},\quad \tilde{\bold r}=\begin{bmatrix} vec(\bold R)\\1\end{bmatrix}
$$
the marginalized optimization problem is then
$$
f=\min_{\bold R\in SO(3)}\underbrace{\tilde{\bold r}^T\tilde{\bold Q}\tilde{\bold r}}_{q(\tilde{\bold r})},\quad \tilde{\bold r}=\begin{bmatrix} vec(\bold R)\\1\end{bmatrix}\label{eq:lg_01}
$$
where $\tilde{\bold Q}=\tilde{\bold M}/\tilde{\bold M}_{\bold t,\bold t}$. 

### SO(3) constraints

in $\refeq{eq:lg_01}$, the $SO(3)$ constraints are as follows
$$
SO(3)=\{\bold R\in \R^{3\times3}:\,\bold R^T\bold R=\bold I_3,det(\bold R)=+1\}
$$
the orthonormality is quadratic, but the determinant constraint is cubic. 

### TIMs

translation invariant measurement where $\bar{\bold b}_{ij}=\bold b_i-\bold b_j$, $\bar{\bold a}_{ij}=\bold a_i-\bold a_j$. (Construct with complete graph, can be simplified with max clique)
$$
\bar{\bold b}_{ij}=R\bar {\bold a}_{ij}+\bold o_{ij}+\bold{\epsilon}_{ij}
$$
in $\eqref{eq:op_1}$, set $\bold x$ as $\bold R$, $\bold y_i$ as $\bar{\bold b}_{ij},\bar {\bold a}_{ij}$. 
$$
r(\bar{\bold b}_{ij},\bar {\bold a}_{ij},\bold R)=\bar{\bold b}_{ij}-\bold R*\bar {\bold a}_{ij}
$$

### Robustness Test


$$
d(R,R_0)=|arccos((tr(R^TR_0)-1)/2)|
$$
