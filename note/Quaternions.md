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
\min_{\bold x \in \chi} \sum_{i=1}^{N} r^{2}(\bold y_{i},\bold x) \label{eq:op_1}
$$
where $x$ is the variable to estimate, e.g. the pose in ICP problems, 

$\chi$ is the domain of $x$, e.g. $SO(3)$ in ICP problems, 

$\bold y_{i}$ is the $i^{th}$ measurement, 

the function $r(\bold y_{i},\bold x)$ is the residual for the $i^{th}$ measurement. 

Generally $\eqref{eq:op_1}$ is difficult to solve globally, due to the nonlinearity of the residual function and non-convexity of $\chi$. Further more, in the presence of outliers, $\eqref{eq:op_1}$ gives false estimation. This call for a robust cost $\rho(\cdot)$
$$
\min_{\bold x \in \chi} \sum_{i=1}^{N} \rho (r(\bold y_{i},\bold x)) \label{eq:op_2}
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
\rho_\mu(r)=\frac{\mu \bar c^2 r^2}{\mu \bar c^2+r^2} \label{eq:GM}
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

GNC surrogate is
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
