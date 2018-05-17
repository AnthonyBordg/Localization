theory Localization
  imports Main "HOL-Algebra.Group" "HOL-Algebra.Ring"
begin

locale submonoid = monoid M for M (structure) +
  fixes S
  assumes subset : "S \<subseteq> carrier M"
    and m_closed [intro, simp] : "\<lbrakk>x \<in> S; y \<in> S\<rbrakk> \<Longrightarrow> x \<otimes> y \<in> S"
    and one_closed [simp] : "\<one> \<in> S"

lemma (in submonoid) is_submonoid: "submonoid M S"
  by (rule submonoid_axioms)

locale mult_submonoid_of_rng = ring R + submonoid R S for R and S

locale mult_submonoid_of_crng = cring R + mult_submonoid_of_rng R S for R and S

locale eq_obj_rng_of_frac = cring R + mult_submonoid_of_crng R S for R (structure) and S +
  fixes rel
  defines "rel \<equiv> \<lparr>carrier = carrier R \<times> S, eq = \<lambda>(r,s) (r',s'). \<exists>t\<in>S. t \<otimes> ((s'\<otimes> r) \<ominus> (s \<otimes> r')) = \<zero>\<rparr>"

lemma (in abelian_group) minus_to_eq :
  assumes "abelian_group G" and "x \<in> carrier G" and "y \<in> carrier G" and "x \<ominus> y = \<zero>"
  shows "x = y"
  by (metis add.inv_solve_right assms(2) assms(3) assms(4) l_zero minus_eq zero_closed)

lemma (in eq_obj_rng_of_frac) equiv_obj_rng_of_frac:
  shows "equivalence rel"
proof
  show "\<And>x. x \<in> carrier rel \<Longrightarrow> x .=\<^bsub>rel\<^esub> x"
  proof-
    fix x
    assume "x \<in> carrier rel"
    then have f1:"\<one> \<otimes> ((snd x \<otimes> fst x) \<ominus> (snd x \<otimes> fst x)) = \<zero>"
      using rel_def subset l_one minus_eq add.r_inv set_rev_mp by auto
    moreover have "x = (fst x, snd x)"
      by simp
    thus "x .=\<^bsub>rel\<^esub> x" 
      using rel_def one_closed f1 by auto
  qed
  show "\<And>x y. x .=\<^bsub>rel\<^esub> y \<Longrightarrow> x \<in> carrier rel \<Longrightarrow> y \<in> carrier rel \<Longrightarrow> y .=\<^bsub>rel\<^esub> x"
  proof-
    fix x y
    assume a1:"x .=\<^bsub>rel\<^esub> y" and a2:"x \<in> carrier rel" and a3:"y \<in> carrier rel"
    then obtain t where f1:"t \<in> S" and f2:"t \<otimes> ((snd y \<otimes> fst x) \<ominus> (snd x \<otimes> fst y)) = \<zero>"
      using rel_def by fastforce
    then have "(snd x \<otimes> fst y) \<ominus> (snd y \<otimes> fst x) = \<ominus> ((snd y \<otimes> fst x) \<ominus> (snd x \<otimes> fst y))"
      using abelian_group.minus_add abelian_group.minus_minus
      by (smt a2 a3 a_minus_def abelian_group.a_inv_closed add.inv_mult_group is_abelian_group mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse rel_def set_rev_mp subset)
    then have "t \<otimes> ((snd x \<otimes> fst y) \<ominus> (snd y \<otimes> fst x)) = \<zero>"
      using minus_zero r_minus f2
      by (smt a2 a3 f1 mem_Sigma_iff minus_closed partial_object.select_convs(1) prod.collapse rel_def semiring_simprules(3) set_rev_mp subset)
    thus "y .=\<^bsub>rel\<^esub> x"
      using f1 rel_def by auto
  qed
  show "\<And>x y z. x .=\<^bsub>rel\<^esub> y \<Longrightarrow> y .=\<^bsub>rel\<^esub> z \<Longrightarrow> x \<in> carrier rel \<Longrightarrow> y \<in> carrier rel \<Longrightarrow> z \<in> carrier rel \<Longrightarrow> x .=\<^bsub>rel\<^esub> z"
  proof-
    fix x y z
    assume a1:"x .=\<^bsub>rel\<^esub> y" and a2:"y .=\<^bsub>rel\<^esub> z" and a3:"x \<in> carrier rel" and a4:"y \<in> carrier rel" and a5:"z \<in> carrier rel"
    then obtain t where f1:"t \<in> S" and f2:"t \<otimes> ((snd y \<otimes> fst x) \<ominus> (snd x \<otimes> fst y)) = \<zero>"
      using rel_def by fastforce
    then obtain t' where f3:"t' \<in> S" and f4:"t' \<otimes> ((snd z \<otimes> fst y) \<ominus> (snd y \<otimes> fst z)) = \<zero>"
      using rel_def a2 by fastforce
    then have "t \<otimes> (snd y \<otimes> fst x) \<ominus> t \<otimes> (snd x \<otimes> fst y) = \<zero>"
      using f1 subset r_distr f2
      by (smt a3 a4 a_minus_def abelian_group.a_inv_closed is_abelian_group mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse r_minus rel_def subset_iff)
    then have "t' \<otimes> (t \<otimes> (snd y \<otimes> fst x)) \<ominus> t' \<otimes> (t \<otimes> (snd x \<otimes> fst y)) = \<zero>"
      using f3 subset r_distr
      by (smt a3 a4 a_minus_def f1 is_abelian_group mem_Sigma_iff minus_to_eq partial_object.select_convs(1) prod.collapse r_neg rel_def semiring_simprules(3) subset_iff)
    then have f5:"snd z \<otimes> (t' \<otimes> (t \<otimes> (snd y \<otimes> fst x))) \<ominus> snd z \<otimes> (t' \<otimes> (t \<otimes> (snd x \<otimes> fst y))) = \<zero>"
      using a5 rel_def r_distr
      by (smt a3 a4 a_minus_def f1 f3 is_abelian_group mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse r_neg subset subset_iff)
    have "t' \<otimes> (snd z \<otimes> fst y) \<ominus> t' \<otimes> (snd y \<otimes> fst z) = \<zero>"
      using f3 f4 subset r_distr
      by (smt a4 a5 a_minus_def abelian_group.a_inv_closed is_abelian_group mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse r_minus rel_def set_rev_mp)
    then have "t \<otimes> (t' \<otimes> (snd z \<otimes> fst y)) \<ominus> t \<otimes> (t' \<otimes> (snd y \<otimes> fst z)) = \<zero>"
      using f1 subset r_distr
      by (smt a4 a5 a_minus_def f3 is_abelian_group mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse r_neg rel_def subset_iff)
    then have f6:"snd x \<otimes> (t \<otimes> (t' \<otimes> (snd z \<otimes> fst y))) \<ominus> snd x \<otimes> (t \<otimes> (t' \<otimes> (snd y \<otimes> fst z))) = \<zero>"
      using a3 rel_def r_distr
      by (smt a4 a5 a_minus_def f1 f3 is_abelian_group mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse r_neg subset subset_iff)
    have "snd z \<otimes> (t' \<otimes> (t \<otimes> (snd x \<otimes> fst y))) = snd x \<otimes> (t \<otimes> (t' \<otimes> (snd z \<otimes> fst y)))"
      using comm_monoid_axioms_def[of R] f1 f3 subset a3 a4 a5 m_assoc
      by (smt m_lcomm mem_Sigma_iff partial_object.select_convs(1) partial_object_ext_def rel_def semiring_simprules(3) set_rev_mp surjective_pairing)
    then have "snd z \<otimes> (t' \<otimes> (t \<otimes> (snd y \<otimes> fst x))) \<ominus> snd z \<otimes> (t' \<otimes> (t \<otimes> (snd x \<otimes> fst y))) \<oplus> 
      snd x \<otimes> (t \<otimes> (t' \<otimes> (snd z \<otimes> fst y))) \<ominus> snd x \<otimes> (t \<otimes> (t' \<otimes> (snd y \<otimes> fst z))) = 
      snd z \<otimes> (t' \<otimes> (t \<otimes> (snd y \<otimes> fst x))) \<ominus> snd x \<otimes> (t \<otimes> (t' \<otimes> (snd y \<otimes> fst z)))"
        using add.l_inv
        by (smt a3 a4 a5 f1 f3 f5 is_abelian_group local.semiring_axioms mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.collapse rel_def semiring.semiring_simprules(6) subset subset_iff)
    then have f7:"snd z \<otimes> (t' \<otimes> (t \<otimes> (snd y \<otimes> fst x))) \<ominus> snd x \<otimes> (t \<otimes> (t' \<otimes> (snd y \<otimes> fst z))) = \<zero>"
      using f5 f6
      by (smt \<open>snd z \<otimes> (t' \<otimes> (t \<otimes> (snd x \<otimes> fst y))) = snd x \<otimes> (t \<otimes> (t' \<otimes> (snd z \<otimes> fst y)))\<close> \<open>t' \<otimes> (snd z \<otimes> fst y) \<ominus> t' \<otimes> (snd y \<otimes> fst z) = \<zero>\<close> a4 a5 f3 is_abelian_group mem_Sigma_iff minus_to_eq partial_object.select_convs(1) prod.collapse rel_def semiring_simprules(3) subset subset_iff)
    moreover have "(t \<otimes> t' \<otimes> snd y) \<otimes> ((snd z \<otimes> fst x) \<ominus> (snd x \<otimes> fst z)) = ((t \<otimes> t' \<otimes> snd y) \<otimes> (snd z \<otimes> fst x)) \<ominus> ((t \<otimes> t' \<otimes> snd y) \<otimes> (snd x \<otimes> fst z))"
      using r_distr f1 f3 subset a3 a4 a5 rel_def a_minus_def r_minus
      by (smt SigmaE abelian_group.a_inv_closed is_abelian_group monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.sel(1) prod.sel(2) subset_iff)
    moreover have f8:"(t \<otimes> t' \<otimes> snd y) \<otimes> (snd z \<otimes> fst x) = snd z \<otimes> (t' \<otimes> (t \<otimes> (snd y \<otimes> fst x)))"
      using m_assoc comm_monoid_axioms_def[of R] f1 f3 subset a3 a4 a5 rel_def set_rev_mp
      by (smt SigmaE local.semiring_axioms m_lcomm partial_object.select_convs(1) prod.sel(1) prod.sel(2) semiring.semiring_simprules(3))
    moreover have f9:"(t \<otimes> t' \<otimes> snd y) \<otimes> (snd x \<otimes> fst z) = snd x \<otimes> (t \<otimes> (t' \<otimes> (snd y \<otimes> fst z)))"
      using m_assoc comm_monoid_axioms_def[of R] f1 f3 subset a3 a4 a5 rel_def set_rev_mp
      by (smt SigmaE m_comm monoid.m_closed monoid_axioms partial_object.select_convs(1) prod.sel(1) prod.sel(2))
    then have f10:"(t \<otimes> t' \<otimes> snd y) \<otimes> (snd z \<otimes> fst x) \<ominus> (t \<otimes> t' \<otimes> snd y) \<otimes> (snd x \<otimes> fst z) = \<zero>"
      using f7 f8 f9 by simp
    moreover have "t \<otimes> t' \<otimes> snd y \<in> S"
      using f1 f3 a4 rel_def m_closed
      by (simp add: mem_Times_iff)
    then have "(t \<otimes> t' \<otimes> snd y) \<otimes> (snd z \<otimes> fst x \<ominus> snd x \<otimes> fst z) = \<zero>"
      using r_distr subset set_rev_mp f10 calculation(2) by auto
    thus " x .=\<^bsub>rel\<^esub> z"
      using rel_def \<open>t \<otimes> t' \<otimes> snd y \<in> S\<close> by auto
  qed
qed

definition  eq_class_of_rng_of_frac:: "_ \<Rightarrow> 'a \<Rightarrow> 'b \<Rightarrow> _set" (infix "|\<index>" 10)
  where "r |\<^bsub>rel\<^esub> s \<equiv> {(r', s') \<in> carrier rel. (r, s) .=\<^bsub>rel\<^esub> (r', s')}"

lemma class_of_to_rel:
  shows "class_of\<^bsub>rel\<^esub> (r, s) = (r |\<^bsub>rel\<^esub> s)"
  using eq_class_of_def[of rel] eq_class_of_rng_of_frac_def[of rel] 
  by auto

lemma (in eq_obj_rng_of_frac) zero_in_mult_submonoid:
  assumes "\<zero> \<in> S" and "(r, s) \<in> carrier rel" and "(r', s') \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) = (r' |\<^bsub>rel\<^esub> s')"
proof
  show "(r |\<^bsub>rel\<^esub> s) \<subseteq> (r' |\<^bsub>rel\<^esub> s')"
  proof
    fix x
    assume a1:"x \<in> (r |\<^bsub>rel\<^esub> s)"
    have " \<zero> \<otimes> (s' \<otimes> fst x \<ominus> snd x \<otimes> r') = \<zero>"
      using l_zero subset rel_def a1 eq_class_of_rng_of_frac_def
      by (smt abelian_group.minus_closed assms(3) is_abelian_group l_null mem_Collect_eq mem_Sigma_iff monoid.m_closed monoid_axioms old.prod.case partial_object.select_convs(1) subset_iff surjective_pairing)
    thus "x \<in> (r' |\<^bsub>rel\<^esub> s')"
      using assms(1) assms(3) rel_def eq_class_of_rng_of_frac_def
      by (smt SigmaE a1 eq_object.select_convs(1) l_null mem_Collect_eq minus_closed old.prod.case partial_object.select_convs(1) prod.collapse semiring_simprules(3) subset subset_iff)
  qed
  show "(r' |\<^bsub>rel\<^esub> s') \<subseteq> (r |\<^bsub>rel\<^esub> s)"
  proof
    fix x
    assume a1:"x \<in> (r' |\<^bsub>rel\<^esub> s')"
    have " \<zero> \<otimes> (s \<otimes> fst x \<ominus> snd x \<otimes> r) = \<zero>"
      using l_zero subset rel_def a1 eq_class_of_rng_of_frac_def
      by (metis (no_types, lifting) BNF_Def.Collect_case_prodD assms(2) l_null mem_Sigma_iff minus_closed partial_object.select_convs(1) semiring_simprules(3) set_rev_mp)
    thus "x \<in> (r |\<^bsub>rel\<^esub> s)"
      using assms(1) assms(2) rel_def eq_class_of_rng_of_frac_def
      by (smt SigmaE a1 eq_object.select_convs(1) l_null mem_Collect_eq minus_closed old.prod.case partial_object.select_convs(1) prod.collapse semiring_simprules(3) subset subset_iff)
  qed
qed

definition set_eq_class_of_rng_of_frac:: "_ \<Rightarrow> _set" ("set'_class'_of\<index>")
  where "set_class_of\<^bsub>rel\<^esub> \<equiv> {(r |\<^bsub>rel\<^esub> s)| r s. (r, s) \<in> carrier rel}"

term "set_class_of\<^bsub>rel\<^esub>"

(* The lemma below should be moved to theory Congruence in HOL-Algebra *)
lemma elem_eq_class:
  assumes "equivalence S" and "x \<in> carrier S" and "y \<in> carrier S" and "x .=\<^bsub>S\<^esub> y"
  shows "class_of\<^bsub>S\<^esub> x = class_of\<^bsub>S\<^esub> y"
proof
  show "class_of\<^bsub>S\<^esub> x \<subseteq> class_of\<^bsub>S\<^esub> y"
  proof
    fix z
    assume "z \<in> class_of\<^bsub>S\<^esub> x"
    then have "y .=\<^bsub>S\<^esub> z"
      using assms eq_class_of_def[of S x] equivalence.sym[of S x y] equivalence.trans
      by (metis (mono_tags, lifting) mem_Collect_eq)
    thus "z \<in> class_of\<^bsub>S\<^esub> y"
      using \<open>z \<in> class_of\<^bsub>S\<^esub> x\<close>
      by (simp add: eq_class_of_def)
  qed
  show "class_of\<^bsub>S\<^esub> y \<subseteq> class_of\<^bsub>S\<^esub> x"
  proof
    fix z
    assume "z \<in> class_of\<^bsub>S\<^esub> y"
    then have "x .=\<^bsub>S\<^esub> z"
      using assms eq_class_of_def equivalence.trans
      by (metis (mono_tags, lifting) mem_Collect_eq)
    thus "z \<in> class_of\<^bsub>S\<^esub> x"
      using \<open>z \<in> class_of\<^bsub>S\<^esub> y\<close>
      by (simp add: eq_class_of_def)
  qed
qed

context eq_obj_rng_of_frac 
begin

definition carrier_rng_of_frac:: "_ partial_object"
  where "carrier_rng_of_frac \<equiv> \<lparr>carrier = set_class_of\<^bsub>rel\<^esub>\<rparr>"

definition mult_rng_of_frac:: "[_set, _set] \<Rightarrow> _set"
  where "mult_rng_of_frac X Y \<equiv> 
let x' = (SOME x. x \<in> X) in 
let y' = (SOME y. y \<in> Y) in 
(fst x' \<otimes> fst y')|\<^bsub>rel\<^esub> (snd x' \<otimes> snd y')"

definition rec_monoid_rng_of_frac:: "_ monoid"
  where "rec_monoid_rng_of_frac \<equiv>  \<lparr>carrier = set_class_of\<^bsub>rel\<^esub>, mult = mult_rng_of_frac, one = (\<one>|\<^bsub>rel\<^esub> \<one>)\<rparr>"

lemma member_class_to_carrier:
  assumes "x \<in> (r |\<^bsub>rel\<^esub> s)" and "y \<in> (r' |\<^bsub>rel\<^esub> s')"
  shows "(fst x \<otimes> fst y, snd x \<otimes> snd y) \<in> carrier rel"
  using assms rel_def eq_class_of_rng_of_frac_def
  by (metis (no_types, lifting) Product_Type.Collect_case_prodD m_closed mem_Sigma_iff partial_object.select_convs(1) semiring_simprules(3))

lemma member_class_to_member_class:
  assumes "x \<in> (r |\<^bsub>rel\<^esub> s)" and "y \<in> (r' |\<^bsub>rel\<^esub> s')"
  shows "(fst x \<otimes> fst y |\<^bsub>rel\<^esub> snd x \<otimes> snd y) \<in> set_class_of\<^bsub>rel\<^esub>"
  using assms member_class_to_carrier[of x r s y r' s'] set_eq_class_of_rng_of_frac_def[of rel] 
eq_class_of_rng_of_frac_def 
  by auto

lemma closed_mult_rng_of_frac :
  assumes "(r, s) \<in> carrier rel" and "(t, u) \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (t |\<^bsub>rel\<^esub> u) \<in> set_class_of\<^bsub>rel\<^esub>"
proof-
  have "(r, s) .=\<^bsub>rel\<^esub> (r, s)"
    using assms(1) equiv_obj_rng_of_frac equivalence_def[of "rel"] by blast
  then have "(r, s) \<in> (r |\<^bsub>rel\<^esub> s)"
    using assms(1)
    by (simp add: eq_class_of_rng_of_frac_def)
  then have f1:"\<exists>x. x \<in> (r |\<^bsub>rel\<^esub> s)"
    by auto
  have f2:"\<exists>y. y\<in> (t |\<^bsub>rel\<^esub> u)"
    using assms(2) equiv_obj_rng_of_frac equivalence.refl eq_class_of_rng_of_frac_def by fastforce
  show "(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (t |\<^bsub>rel\<^esub> u) \<in> set_class_of\<^bsub>rel\<^esub>"
    using f1 f2 rec_monoid_rng_of_frac_def mult_rng_of_frac_def[of "(r |\<^bsub>rel\<^esub> s)" "(t |\<^bsub>rel\<^esub> u)"] 
set_eq_class_of_rng_of_frac_def[of "rel"] member_class_to_member_class[of x' r s y' t u]
    by (metis (mono_tags, lifting) mem_Collect_eq member_class_to_carrier monoid.select_convs(1) someI_ex)
qed

lemma non_empty_class:
  assumes "(r, s) \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) \<noteq> {}"
  using assms eq_class_of_rng_of_frac_def equiv_obj_rng_of_frac equivalence.refl by fastforce

lemma mult_rng_of_frac_fundamental_lemma:
  assumes "(r, s) \<in> carrier rel" and "(r', s') \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = (r \<otimes> r' |\<^bsub>rel\<^esub> s \<otimes> s')"
proof-
  have f1:"(r |\<^bsub>rel\<^esub> s) \<noteq> {}"
    using assms(1) non_empty_class by auto
  have "(r' |\<^bsub>rel\<^esub> s') \<noteq> {}"
    using assms(2) non_empty_class by auto
  then have "\<exists>x \<in> (r |\<^bsub>rel\<^esub> s). \<exists>x' \<in> (r' |\<^bsub>rel\<^esub> s'). (r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') =
    (fst x \<otimes> fst x' |\<^bsub>rel\<^esub> snd x \<otimes> snd x')"
      using f1 rec_monoid_rng_of_frac_def
      by (metis monoid.select_convs(1) mult_rng_of_frac_def some_in_eq)
  then obtain x and x' where f2:"x \<in> (r |\<^bsub>rel\<^esub> s)" and f3:"x' \<in> (r' |\<^bsub>rel\<^esub> s')" 
    and "(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = (fst x \<otimes> fst x' |\<^bsub>rel\<^esub> snd x \<otimes> snd x')"
    by blast
  then have "(r, s) .=\<^bsub>rel\<^esub> (fst x, snd x)"
    using rel_def
    by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def)
  then obtain t where f4:"t \<in> S" and f5:"t \<otimes> ((snd x \<otimes> r) \<ominus> (s \<otimes> fst x)) = \<zero>"
    using rel_def by auto
  have "(r', s') .=\<^bsub>rel\<^esub> (fst x', snd x')"
    using rel_def f3
    by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def)
  then obtain t' where f6:"t' \<in> S" and f7:"t' \<otimes> (snd x' \<otimes> r' \<ominus> s' \<otimes> fst x') = \<zero>"
    using rel_def by auto
  have f8:"t \<in> carrier R"
    using f4 subset set_rev_mp by auto
  have f9:"snd x \<otimes> r \<in> carrier R" 
    using subset set_rev_mp f2 assms(1)
    by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3))
  have f10:"\<ominus> (s \<otimes> fst x) \<in> carrier R"
    using assms(1) subset set_rev_mp f2
    by (metis (no_types, lifting) BNF_Def.Collect_case_prodD abelian_group.a_inv_closed eq_class_of_rng_of_frac_def is_abelian_group mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def)
  then have "t \<otimes> (snd x \<otimes> r) \<ominus> t \<otimes> (s \<otimes> fst x) = \<zero>"
    using f8 f9 f10 f5 r_distr[of "snd x \<otimes> r" "\<ominus> (s \<otimes> fst x)" t] a_minus_def r_minus[of t "s \<otimes> fst x"]
    by (smt BNF_Def.Collect_case_prodD assms(1) eq_class_of_rng_of_frac_def f2 mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3) subset subset_iff)
  then have f11:"t \<otimes> (snd x \<otimes> r) = t \<otimes> (s \<otimes> fst x)"
    by (smt BNF_Def.Collect_case_prodD assms(1) eq_class_of_rng_of_frac_def f2 f8 is_abelian_group mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  have f12:"t' \<in> carrier R"
    using f6 subset set_rev_mp by auto
  have f13:"snd x' \<otimes> r' \<in> carrier R"
    using assms(2) f3 subset set_rev_mp
    by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def)
  have f14:"\<ominus> (s' \<otimes> fst x') \<in> carrier R"
    using assms(2) f3 subset set_rev_mp
    by (metis (no_types, lifting) BNF_Def.Collect_case_prodD abelian_group.a_inv_closed eq_class_of_rng_of_frac_def is_abelian_group mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def)
  then have "t' \<otimes> (snd x' \<otimes> r') \<ominus> t' \<otimes> (s' \<otimes> fst x') = \<zero>"
    using f12 f13 f14 f7 r_distr[of "snd x' \<otimes> r'" "\<ominus> (s' \<otimes> fst x')" t'] a_minus_def r_minus[of t' "s' \<otimes> fst x'"]
    by (smt BNF_Def.Collect_case_prodD assms(2) eq_class_of_rng_of_frac_def f3 mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3) subset subset_iff)
  then have f15:"t' \<otimes> (snd x' \<otimes> r') = t' \<otimes> (s' \<otimes> fst x')"
    by (smt BNF_Def.Collect_case_prodD assms(2) eq_class_of_rng_of_frac_def f3 f12 is_abelian_group mem_Sigma_iff minus_to_eq monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  have "t' \<otimes> t \<in> S"
    using f4 f6 m_closed by auto
  then have f16:"t' \<otimes> t \<in> carrier R"
    using subset set_rev_mp by auto
  have f17:"(snd x \<otimes> snd x') \<otimes> (r \<otimes> r') \<in> carrier R"
    using assms f2 f3
    by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  have f18:"(s \<otimes> s') \<otimes> (fst x \<otimes> fst x') \<in> carrier R"
    using assms f2 f3
    by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  then have f19:"(t' \<otimes> t) \<otimes> ((snd x \<otimes> snd x') \<otimes> (r \<otimes> r') \<ominus> (s \<otimes> s') \<otimes> (fst x \<otimes> fst x')) = 
    ((t' \<otimes> t) \<otimes> (snd x \<otimes> snd x')) \<otimes> (r \<otimes> r') \<ominus> (t' \<otimes> t) \<otimes> ((s \<otimes> s') \<otimes> (fst x \<otimes> fst x'))"
      using f16 f17 f18 r_distr m_assoc r_minus a_minus_def
      by (smt BNF_Def.Collect_case_prodD assms(1) assms(2) eq_class_of_rng_of_frac_def f14 f2 f3 m_comm mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  then have f20:"(t' \<otimes> t) \<otimes> (snd x \<otimes> snd x') \<otimes> (r \<otimes> r') = (t' \<otimes> t) \<otimes> (snd x \<otimes> r \<otimes> snd x' \<otimes> r')"
    using m_assoc m_comm f16 assms rel_def f2 f3
    by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1) semiring_simprules(3) subset subset_iff)
  then have "((t' \<otimes> t) \<otimes> (snd x \<otimes> snd x')) \<otimes> (r \<otimes> r') = t' \<otimes> ((t \<otimes> snd x \<otimes> r) \<otimes> snd x' \<otimes> r')"
    using m_assoc assms f2 f3 rel_def f8 f12
    by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) subset subset_iff)
  then have f21:"((t' \<otimes> t) \<otimes> (snd x \<otimes> snd x')) \<otimes> (r \<otimes> r') = t' \<otimes> (t \<otimes> s \<otimes> fst x) \<otimes> snd x' \<otimes> r'"
    using f11 m_assoc
    by (smt BNF_Def.Collect_case_prodD assms(1) assms(2) eq_class_of_rng_of_frac_def f12 f2 f3 f8 mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def subset subset_iff)
  moreover have "(t' \<otimes> t) \<otimes> ((s \<otimes> s') \<otimes> (fst x \<otimes> fst x')) = (t' \<otimes> s' \<otimes> fst x') \<otimes> t \<otimes> s \<otimes> fst x"
    using assms f2 f3 f8 f12 m_assoc m_comm rel_def
    by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) subset subset_iff)
  then have "(t' \<otimes> t) \<otimes> ((s \<otimes> s') \<otimes> (fst x \<otimes> fst x')) = (t' \<otimes> snd x' \<otimes> r') \<otimes> t \<otimes> s \<otimes> fst x"
    using f15 m_assoc
    by (smt BNF_Def.Collect_case_prodD assms(2) eq_class_of_rng_of_frac_def f12 f3 mem_Sigma_iff partial_object.select_convs(1) rel_def subset subset_iff)
  then have f22:"(t' \<otimes> t) \<otimes> ((s \<otimes> s') \<otimes> (fst x \<otimes> fst x')) = t' \<otimes> ((t \<otimes> snd x \<otimes> r) \<otimes> snd x' \<otimes> r')"
    using m_assoc m_comm assms
    by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def f12 f2 f21 f3 f8 mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3) subset subset_iff)
  then have f23:"(t' \<otimes> t) \<otimes> ((snd x \<otimes> snd x') \<otimes> (r \<otimes> r') \<ominus> (s \<otimes> s') \<otimes> (fst x \<otimes> fst x')) = \<zero>"
    using f19 f21 f22
    by (metis \<open>t' \<otimes> t \<otimes> (snd x \<otimes> snd x') \<otimes> (r \<otimes> r') = t' \<otimes> (t \<otimes> snd x \<otimes> r \<otimes> snd x' \<otimes> r')\<close> a_minus_def f16 f18 r_neg semiring_simprules(3))
  have f24:"(r \<otimes> r', s \<otimes> s') \<in> carrier rel"
    using assms rel_def by auto
  have f25: "(fst x \<otimes> fst x', snd x \<otimes> snd x') \<in> carrier rel"
    using f2 f3 member_class_to_carrier by auto
  then have "(r \<otimes> r', s \<otimes> s') .=\<^bsub>rel\<^esub> (fst x \<otimes> fst x', snd x \<otimes> snd x')"
    using f23 f24 rel_def \<open>t' \<otimes> t \<in> S\<close> by auto
  then have "class_of\<^bsub>rel\<^esub> (r \<otimes> r', s \<otimes> s') = class_of\<^bsub>rel\<^esub> (fst x \<otimes> fst x', snd x \<otimes> snd x')"
    using f24 f25 equiv_obj_rng_of_frac elem_eq_class[of rel "(r \<otimes> r', s \<otimes> s')" "(fst x \<otimes> fst x', snd x \<otimes> snd x')"] 
      eq_class_of_rng_of_frac_def by auto
  then have "(r \<otimes> r' |\<^bsub>rel\<^esub> s \<otimes> s') = (fst x \<otimes> fst x' |\<^bsub>rel\<^esub> snd x \<otimes> snd x')"
    using class_of_to_rel[of rel] by auto
  thus ?thesis
    using \<open>(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = (fst x \<otimes> fst x' |\<^bsub>rel\<^esub> snd x \<otimes> snd x')\<close> 
      trans sym by auto
qed

lemma member_class_to_assoc:
  assumes "x \<in> (r |\<^bsub>rel\<^esub> s)" and "y \<in> (t |\<^bsub>rel\<^esub> u)" and "z \<in> (v |\<^bsub>rel\<^esub> w)"
  shows "((fst x \<otimes> fst y) \<otimes> fst z |\<^bsub>rel\<^esub> (snd x \<otimes> snd y) \<otimes> snd z) = (fst x \<otimes> (fst y \<otimes> fst z) |\<^bsub>rel\<^esub> snd x \<otimes> (snd y \<otimes> snd z))"
  using assms m_assoc subset rel_def set_rev_mp
  by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1))

lemma assoc_mult_rng_of_frac:
  assumes "(r, s) \<in> carrier rel" and "(t, u) \<in> carrier rel" and "(v, w) \<in> carrier rel"
  shows "((r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (t |\<^bsub>rel\<^esub> u)) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (v |\<^bsub>rel\<^esub> w) =
         (r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> ((t |\<^bsub>rel\<^esub> u) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (v |\<^bsub>rel\<^esub> w))"
proof-
  have "((r \<otimes> t) \<otimes> v, (s \<otimes> u) \<otimes> w) = (r \<otimes> (t \<otimes> v), s \<otimes> (u \<otimes> w))"
    using assms m_assoc
    by (metis (no_types, lifting) mem_Sigma_iff partial_object.select_convs(1) rel_def set_rev_mp subset)
  then have f1:"((r \<otimes> t) \<otimes> v |\<^bsub>rel\<^esub> (s \<otimes> u) \<otimes> w) = (r \<otimes> (t \<otimes> v) |\<^bsub>rel\<^esub> s \<otimes> (u \<otimes> w))"
    by simp
  have f2:"((r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (t |\<^bsub>rel\<^esub> u)) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (v |\<^bsub>rel\<^esub> w) =
    ((r \<otimes> t) \<otimes> v |\<^bsub>rel\<^esub> (s \<otimes> u) \<otimes> w)"
    using assms mult_rng_of_frac_fundamental_lemma rel_def by auto
  have f3:"(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> ((t |\<^bsub>rel\<^esub> u) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (v |\<^bsub>rel\<^esub> w)) =
    (r \<otimes> (t \<otimes> v) |\<^bsub>rel\<^esub> s \<otimes> (u \<otimes> w))"
    using assms mult_rng_of_frac_fundamental_lemma rel_def by auto
  thus ?thesis
    using f1 f2 f3 by simp
qed

lemma left_unit_mult_rng_of_frac:
  assumes "(r, s) \<in> carrier rel"
  shows "\<one>\<^bsub>rec_monoid_rng_of_frac\<^esub> \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (r |\<^bsub>rel\<^esub> s) = (r |\<^bsub>rel\<^esub> s)"
  using assms subset set_rev_mp rec_monoid_rng_of_frac_def mult_rng_of_frac_fundamental_lemma[of \<one> \<one> r s] 
    l_one[of r] l_one[of s] rel_def by auto

lemma right_unit_mult_rng_of_frac:
  assumes "(r, s) \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> \<one>\<^bsub>rec_monoid_rng_of_frac\<^esub> = (r |\<^bsub>rel\<^esub> s)"
  using assms subset set_rev_mp rec_monoid_rng_of_frac_def mult_rng_of_frac_fundamental_lemma[of r s \<one> \<one>]
    r_one[of r] r_one[of s] rel_def by auto

lemma monoid_rng_of_frac:
  shows "monoid (rec_monoid_rng_of_frac)"
proof
  show "\<And>x y. x \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow>
           y \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow> x \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> y \<in> carrier rec_monoid_rng_of_frac"
    using rec_monoid_rng_of_frac_def closed_mult_rng_of_frac
    by (smt mem_Collect_eq partial_object.select_convs(1) set_eq_class_of_rng_of_frac_def)
  show "\<And>x y z. x \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow>
             y \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow>
             z \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow>
             x \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> y \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> z =
             x \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> (y \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> z)"
    using assoc_mult_rng_of_frac
    by (smt mem_Collect_eq partial_object.select_convs(1) rec_monoid_rng_of_frac_def set_eq_class_of_rng_of_frac_def)
  show "\<one>\<^bsub>rec_monoid_rng_of_frac\<^esub> \<in> carrier rec_monoid_rng_of_frac"
    using rec_monoid_rng_of_frac_def rel_def set_eq_class_of_rng_of_frac_def by fastforce
  show "\<And>x. x \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow> \<one>\<^bsub>rec_monoid_rng_of_frac\<^esub> \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> x = x"
    using left_unit_mult_rng_of_frac
    by (smt mem_Collect_eq partial_object.select_convs(1) rec_monoid_rng_of_frac_def set_eq_class_of_rng_of_frac_def)
  show "\<And>x. x \<in> carrier rec_monoid_rng_of_frac \<Longrightarrow> x \<otimes>\<^bsub>rec_monoid_rng_of_frac\<^esub> \<one>\<^bsub>rec_monoid_rng_of_frac\<^esub> = x"
    using right_unit_mult_rng_of_frac
    by (smt mem_Collect_eq partial_object.select_convs(1) rec_monoid_rng_of_frac_def set_eq_class_of_rng_of_frac_def)
qed

definition add_rng_of_frac:: "[_set, _set] \<Rightarrow> _set"
  where "add_rng_of_frac X Y \<equiv> 
let x' = (SOME x. x \<in> X) in 
let y' = (SOME y. y \<in> Y) in 
(snd y' \<otimes> fst x' \<oplus> snd x' \<otimes> fst y') |\<^bsub>rel\<^esub> (snd x' \<otimes> snd y')"

definition rec_rng_of_frac:: "_ ring"
  where "rec_rng_of_frac \<equiv> 
\<lparr>carrier = set_class_of\<^bsub>rel\<^esub>, mult = mult_rng_of_frac, one = (\<one>|\<^bsub>rel\<^esub> \<one>), zero = (\<zero> |\<^bsub>rel\<^esub> \<one>), add = add_rng_of_frac \<rparr>"

lemma add_rng_of_frac_fundamental_lemma:
  assumes "(r, s) \<in> carrier rel" and "(r', s') \<in> carrier rel"
  shows "(r |\<^bsub>rel\<^esub> s) \<oplus>\<^bsub>rec_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = (s' \<otimes> r \<oplus> s \<otimes> r' |\<^bsub>rel\<^esub> s \<otimes> s')"
proof-
  have "\<exists>x' \<in> (r |\<^bsub>rel\<^esub> s). \<exists>y' \<in> (r' |\<^bsub>rel\<^esub> s'). (r |\<^bsub>rel\<^esub> s) \<oplus>\<^bsub>rec_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = 
    (snd y' \<otimes> fst x' \<oplus> snd x' \<otimes> fst y' |\<^bsub>rel\<^esub> snd x' \<otimes> snd y')"
    using assms rec_rng_of_frac_def add_rng_of_frac_def[of "(r |\<^bsub>rel\<^esub> s)" "(r' |\<^bsub>rel\<^esub> s')"]
    by (metis non_empty_class ring_record_simps(12) some_in_eq)
  then obtain x' and y' where f1:"x' \<in> (r |\<^bsub>rel\<^esub> s)" and f2:"y' \<in> (r' |\<^bsub>rel\<^esub> s')" and 
    f3:"(r |\<^bsub>rel\<^esub> s) \<oplus>\<^bsub>rec_rng_of_frac\<^esub> (r' |\<^bsub>rel\<^esub> s') = (snd y' \<otimes> fst x' \<oplus> snd x' \<otimes> fst y' |\<^bsub>rel\<^esub> snd x' \<otimes> snd y')"
    by auto
  then have "(r, s) .=\<^bsub>rel\<^esub> x'"
    using f1 rel_def eq_class_of_rng_of_frac_def[of rel r s]
    by auto
  then obtain t where f4:"t \<in> S" and f5:"t \<otimes> (snd x' \<otimes> r \<ominus> s \<otimes> fst x') = \<zero>"
    using rel_def by auto
  have "(r', s') .=\<^bsub>rel\<^esub> y'"
    using f2 rel_def eq_class_of_rng_of_frac_def[of rel r' s']
    by auto
  then obtain t' where f6:"t' \<in> S" and f7:"t' \<otimes> (snd y' \<otimes> r' \<ominus> s' \<otimes> fst y') = \<zero>"
    using rel_def by auto
  then have f8:"t \<otimes> t' \<in> S"
    using m_closed f4 f6
    by simp
  then have "(s' \<otimes> r \<oplus> s \<otimes> r', s \<otimes> s') .=\<^bsub>rel\<^esub> (snd y' \<otimes> fst x' \<oplus> snd x' \<otimes> fst y', snd x' \<otimes> snd y')"
  proof-
    have f9:"t' \<otimes> s' \<otimes> snd y' \<in> carrier R"
      using f6 assms(2) f2 subset set_rev_mp eq_class_of_rng_of_frac_def rel_def 
      by fastforce
    have f10:"snd x' \<otimes> r \<in> carrier R"
      using assms(1) f1 rel_def subset set_rev_mp
      by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1) semiring_simprules(3))
    have f11:"s \<otimes> fst x' \<in> carrier R"
      using assms(1) subset set_rev_mp f1 rel_def
      by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1) semiring_simprules(3)) 
    have "t \<otimes> (snd x' \<otimes> r \<ominus> s \<otimes> fst x') = t \<otimes> (snd x' \<otimes> r) \<ominus> t \<otimes> (s \<otimes> fst x')"
      using f9 f10 f11 f4 subset set_rev_mp r_distr[of "snd x' \<otimes> r" "s \<otimes> fst x'" t] a_minus_def r_minus[of t "s \<otimes> fst x'"]
      by (smt add.inv_closed monoid.m_closed monoid_axioms r_distr)
    then have f12:"(t' \<otimes> s' \<otimes> snd y') \<otimes> (t \<otimes> (snd x' \<otimes> r \<ominus> s \<otimes> fst x')) =
      t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (snd x' \<otimes> r) \<ominus> (t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (s \<otimes> fst x'))"
      using f9 r_distr[of _ _ "t' \<otimes> s' \<otimes> snd y'"] rel_def r_minus a_minus_def
      by (smt abelian_group.minus_to_eq f10 f11 f4 f5 is_abelian_group m_assoc monoid.m_closed monoid_axioms r_neg r_null subset subset_iff)
    have f13:"(snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r) \<in> carrier R"
      using assms f1 f2 subset set_rev_mp
      by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def)
    have f14:"(s \<otimes> s') \<otimes> (snd y' \<otimes> fst x') \<in> carrier R"
      using assms f1 f2 subset set_rev_mp
      by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid.m_closed monoid_axioms partial_object.select_convs(1) rel_def)
    then have "(t \<otimes> t') \<otimes> ((snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r) \<ominus> (s \<otimes> s') \<otimes> (snd y' \<otimes> fst x')) =
      (t \<otimes> t') \<otimes> ((snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r)) \<ominus> (t \<otimes> t') \<otimes> ((s \<otimes> s') \<otimes> (snd y' \<otimes> fst x'))"
      using f13 f14 f8 subset set_rev_mp r_distr rel_def r_minus a_minus_def
      by (smt add.inv_closed semiring_simprules(3))
    have f15:"s \<otimes> s' \<in> carrier R"
      using assms rel_def subset set_rev_mp by auto
    have f16:"snd y' \<otimes> fst x' \<in> carrier R"
      using f1 f2 rel_def subset set_rev_mp[of _ S] monoid.m_closed[of R "snd y'" "fst x'"]
      by (metis (no_types, lifting) BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff monoid_axioms partial_object.select_convs(1))
    have f17:"t \<in> carrier R"
      using f4 subset set_rev_mp by auto
    have f18:"t' \<in> carrier R"
      using f6 subset set_rev_mp by auto
    have f19:"s \<in> carrier R"
      using assms(1) rel_def subset by auto
    have f20:"s' \<in> carrier R"
      using assms(2) rel_def subset by auto
    have f21:"snd y' \<in> carrier R"
      using f2 rel_def subset set_rev_mp
      by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1))
    have f22:"fst x' \<in> carrier R"
      using f1 rel_def
      by (metis (no_types, lifting) Product_Type.Collect_case_prodD eq_class_of_rng_of_frac_def mem_Sigma_iff partial_object.select_convs(1))
    then have f23:"(t \<otimes> t') \<otimes> ((s \<otimes> s') \<otimes> (snd y' \<otimes> fst x')) = t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (s \<otimes> fst x')"
      using f17 f18 f19 f20 f21 m_assoc m_comm 
      by (smt BNF_Def.Collect_case_prodD eq_class_of_rng_of_frac_def f1 f4 f6 mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3) subset_iff) 
    have f24:"(t \<otimes> t') \<otimes> ((snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r)) = t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (snd x' \<otimes> r)"
      using f17 f18 f20 f21 m_assoc m_comm
      by (smt BNF_Def.Collect_case_prodD assms(1) eq_class_of_rng_of_frac_def f1 f2 f4 f6 mem_Sigma_iff partial_object.select_convs(1) rel_def semiring_simprules(3) subset subset_iff) 
    then have "(t \<otimes> t') \<otimes> ((snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r)) \<ominus> (t \<otimes> t') \<otimes> ((s \<otimes> s') \<otimes> (snd y' \<otimes> fst x'))=
      (t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (snd x' \<otimes> r)) \<ominus> (t' \<otimes> s' \<otimes> snd y' \<otimes> t \<otimes> (s \<otimes> fst x'))"
      using f23 f24 by simp
    then have f25:"(t' \<otimes> s' \<otimes> snd y') \<otimes> (t \<otimes> (snd x' \<otimes> r \<ominus> s \<otimes> fst x')) = 
      (t \<otimes> t') \<otimes> ((snd x' \<otimes> snd y') \<otimes> (s' \<otimes> r)) \<ominus> (t \<otimes> t') \<otimes> ((s \<otimes> s') \<otimes> (snd y' \<otimes> fst x'))"
      using f12 by simp
