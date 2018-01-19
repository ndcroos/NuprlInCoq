(*

  Copyright 2014 Cornell University
  Copyright 2015 Cornell University
  Copyright 2016 Cornell University
  Copyright 2017 Cornell University
  Copyright 2018 Cornell University

  This file is part of VPrl (the Verified Nuprl project).

  VPrl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VPrl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VPrl.  If not, see <http://www.gnu.org/licenses/>.


  Websites: http://nuprl.org/html/verification/
            http://nuprl.org/html/Nuprl2Coq
            https://github.com/vrahli/NuprlInCoq

  Authors: Vincent Rahli

*)


Require Export rules_useful.
Require Export subst_tacs_aeq.
Require Export subst_tacs3.
Require Export cequiv_tacs.
Require Export cequiv_props3.
Require Export per_props_equality.
Require Export per_props_product.
Require Export per_props_nat.
Require Export per_props_squash.
Require Export sequents_equality.
Require Export sequents_tacs2.
Require Export rules_tyfam.
Require Export lsubst_hyps.
Require Export terms_pi.
Require Export per_props_natk2nat.
Require Export fresh_cs.


Definition entry_free_from_choice_seq_name {o} (e : @library_entry o) (name : choice_sequence_name) :=
  match e with
  | lib_cs n l =>
    if choice_sequence_name_deq n name then False
    else True
  | lib_abs _ _ _ _ => True
  end.

Fixpoint lib_free_from_choice_seq_name {o} (lib : @library o) (name : choice_sequence_name) :=
  match lib with
  | [] => True
  | e :: es =>
    (entry_free_from_choice_seq_name e name)
      # lib_free_from_choice_seq_name es name
  end.

Definition sequent_true_ex_ext {o} lib (s : @csequent o) :=
  {lib' : library & lib_extends lib' lib # sequent_true lib' s}.

Definition rule_true_ex_ext {o} lib (R : @rule o) : Type :=
  forall wg : wf_sequent (goal R),
  forall cg : closed_type_baresequent (goal R),
  forall cargs: args_constraints (sargs R) (hyps (goal R)),
  forall hyps : (forall s : baresequent,
                   LIn s (subgoals R)
                   -> {c : wf_csequent s & sequent_true lib (mk_wcseq s c)}),
    {c : closed_extract_baresequent (goal R)
     & sequent_true_ex_ext lib (mk_wcseq (goal R) (ext_wf_cseq (goal R) wg cg c))}.


Definition ls1 {o} (n f a : NVar) : @NTerm o :=
  mk_function
    mk_tnat
    n
    (mk_function
       (mk_natk2nat (mk_var n))
       f
       (mk_squash
          (mk_exists
             (mk_csname 0)
             a
             (mk_equality
                (mk_var f)
                (mk_var a)
                (mk_natk2nat (mk_var n)))))).

Definition ls1c {o} (n f a : NVar) : @CTerm o :=
  mkc_function
    mkc_tnat
    n
    (mkcv_function
       _
       (mkcv_natk2nat _ (mkc_var n))
       f
       (mkcv_squash
          _
          (mkcv_exists
             _
             (mkcv_csname _ 0)
             a
             (mkcv_equality
                [a,f,n]
                (mk_cv_app_l [a] _ (mk_cv_app_r [n] _ (mkc_var f)))
                (mk_cv_app_r [f,n] _ (mkc_var a))
                (mk_cv_app_l [a,f] _ (mkcv_natk2nat _ (mkc_var n))))))).

Definition ls1_extract {o} (name : choice_sequence_name) (n f : NVar) : @NTerm o :=
  mk_lam n (mk_lam f mk_axiom).

Lemma rename_nvars_cons_left :
  forall a k l, remove_nvars (a :: k) (a :: l) = remove_nvars (a :: k) l.
Proof.
  introv.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars_cons_left : slow.

Lemma rename_nvars_cons_cons :
  forall a b k l, remove_nvars (a :: k) (b :: a :: l) = remove_nvars (a :: k) (b :: l).
Proof.
  introv.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars_cons_cons : slow.

Lemma rename_nvars2_cons :
  forall a b k j l,
    remove_nvars (a :: k) (remove_nvars (b :: j) (a :: l))
    = remove_nvars (a :: k) (remove_nvars (b :: j) l).
Proof.
  introv.
  repeat (rewrite remove_nvars_app_l); simpl.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars2_cons : slow.

Lemma rename_nvars3_cons :
  forall a1 a2 a3 k1 k2 k3 l,
    remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) (a1 :: l)))
    = remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) l)).
Proof.
  introv.
  repeat (rewrite remove_nvars_app_l); simpl.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars3_cons : slow.

Lemma rename_nvars4_cons :
  forall a1 a2 a3 a4 k1 k2 k3 k4 l,
    remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) (remove_nvars (a4 :: k4) (a1 :: l))))
    = remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) (remove_nvars (a4 :: k4) l))).
Proof.
  introv.
  repeat (rewrite remove_nvars_app_l); simpl.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars4_cons : slow.

Lemma rename_nvars5_cons :
  forall a1 a2 a3 a4 a5 k1 k2 k3 k4 k5 l,
    remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) (remove_nvars (a4 :: k4) (remove_nvars (a5 :: k5) (a1 :: l)))))
    = remove_nvars (a1 :: k1) (remove_nvars (a2 :: k2) (remove_nvars (a3 :: k3) (remove_nvars (a4 :: k4) (remove_nvars (a5 :: k5) l)))).
Proof.
  introv.
  repeat (rewrite remove_nvars_app_l); simpl.
  unfold remove_nvars; simpl; boolvar; auto; tcsp.
Qed.
Hint Rewrite rename_nvars5_cons : slow.

Hint Rewrite remove_nvars_app_r : slow.
Hint Rewrite remove_nvars_nil_r : slow.
Hint Rewrite app_nil_l : slow.

Lemma lsubstc_ls1_eq {o} :
  forall n f a (w : @wf_term o (ls1 n f a)) s c,
    lsubstc (ls1 n f a) w s c = ls1c n f a.
Proof.
  introv.
  apply cterm_eq; simpl.
  apply csubst_trivial; simpl; autorewrite with slow; auto.
Qed.
Hint Rewrite @lsubstc_ls1_eq : slow.

(* MOVE *)
Lemma tequality_mkc_tnat {o} : forall lib, @tequality o lib mkc_tnat mkc_tnat.
Proof.
  introv; apply tnat_type.
Qed.
Hint Resolve tequality_mkc_tnat : slow.

Lemma fold_image {o} :
  forall (a b : @NTerm o),
    oterm (Can NImage) [nobnd a, nobnd b]
    = mk_image a b.
Proof.
  tcsp.
Qed.

Lemma fold_mk_squash {o} :
  forall (a : @NTerm o),
    mk_image a (mk_lam nvarx mk_axiom) = mk_squash a.
Proof.
  tcsp.
Qed.

Lemma implies_alpha_eq_mk_squash {o} :
  forall (a b : @NTerm o),
    alpha_eq a b
    -> alpha_eq (mk_squash a) (mk_squash b).
Proof.
  introv aeq.
  constructor; simpl; auto.
  introv len.
  repeat (destruct n; tcsp).
  unfold selectbt; simpl.
  apply alpha_eq_bterm_congr; auto.
Qed.

Lemma implies_alpha_eq_mk_product {o} :
  forall x v (a b : @NTerm o),
    alpha_eq a b
    -> alpha_eq (mk_product x v a) (mk_product x v b).
Proof.
  introv aeq.
  constructor; simpl; auto.
  introv len.
  repeat (destruct n; tcsp).
  unfold selectbt; simpl.
  apply alpha_eq_bterm_congr; auto.
Qed.

Lemma implies_alpha_eq_mk_equality {o} :
  forall x y (a b : @NTerm o),
    alpha_eq a b
    -> alpha_eq (mk_equality x y a) (mk_equality x y b).
Proof.
  introv aeq.
  constructor; simpl; auto.
  introv len.
  repeat (destruct n; tcsp).
  unfold selectbt; simpl.
  apply alpha_eq_bterm_congr; auto.
Qed.

Lemma subst_ls1_cond1 {o} :
  forall n f a (t : @CTerm o) (d1 : n <> a) (d2 : n <> f),
    alphaeqcv
      _
      (substcv
         [f] t n
         (mkcv_squash
            _
            (mkcv_exists
               _
               (mkcv_csname _ 0)
               a
               (mkcv_equality
                  _
                  (mk_cv_app_l [a] ([f] ++ [n]) (mk_cv_app_r [n] [f] (mkc_var f)))
                  (mk_cv_app_r [f, n] [a] (mkc_var a))
                  (mk_cv_app_l [a, f] [n] (mkcv_natk2nat [n] (mkc_var n)))))))
      (mkcv_squash
         [f]
         (mkcv_exists
            _
            (mkcv_csname _ 0)
            a
            (mkcv_equality
               _
               (mk_cv_app_l [a] _ (mkc_var f))
               (mk_cv_app_r [f] [a] (mkc_var a))
               (mk_cv _ (natk2nat t))))).
Proof.
  introv d1 d2.
  destruct_cterms.
  unfold alphaeqcv; simpl.
  unfsubst; simpl.

  autorewrite with slow.
  boolvar; tcsp.
  fold_terms.
  simpl.
  repeat (autorewrite with slow; rewrite beq_var_newvar_trivial1; simpl; tcsp;[]).
  boolvar; tcsp;[].

  allrw @fold_image.
  allrw @fold_mk_squash.
  allrw @fold_csname.
  apply implies_alpha_eq_mk_squash.
  apply implies_alpha_eq_mk_product.
  apply implies_alpha_eq_mk_equality.

  fold (mk_natk2nat x).

  pose proof (substc_mkcv_natk2nat n (mkc_var n) (mk_ct x i)) as q.
  unfold alphaeqc in q; simpl in q.
  unfsubst in q; simpl in q.

  repeat (autorewrite with slow in q; rewrite beq_var_newvar_trivial1 in q; simpl in q; tcsp;[]).
  fold_terms.

  unfsubst in q; simpl in *; boolvar; tcsp.
Qed.

Lemma implies_alphaeqc_mk_function {o} :
  forall x v (a b : @CVTerm o [v]),
    alphaeqcv [v] a b
    -> alphaeqc (mkc_function x v a) (mkc_function x v b).
Proof.
  introv aeq.
  destruct_cterms.
  unfold alphaeqc, alphaeqcv in *; simpl in *.
  constructor; simpl; auto.
  introv len.
  repeat (destruct n; tcsp).
  unfold selectbt; simpl.
  apply alpha_eq_bterm_congr; auto.
Qed.

Lemma substc_mkcv_csname {o} :
  forall v (t : @CTerm o) n,
    substc t v (mkcv_csname [v] n) = mkc_csname n.
Proof.
  introv; destruct_cterms; apply cterm_eq; simpl; auto.
Qed.
Hint Rewrite @substc_mkcv_csname : slow.

Lemma dest_nuprl_csname {o} :
  forall (lib : @library o) eq n,
    nuprl lib (mkc_csname n) (mkc_csname n) eq
    -> per_bar (per_csname nuprl) lib (mkc_csname n) (mkc_csname n) eq.
Proof.
  introv cl.
  eapply dest_close_per_csname_l in cl;
    try (apply computes_to_valc_refl; eauto 3 with slow); eauto 3 with slow.
Qed.

Lemma dest_nuprl_csname2 {o} :
  forall lib (eq : per(o)) n,
    nuprl lib (mkc_csname n) (mkc_csname n) eq
    -> eq <=2=> (equality_of_csname_bar lib n).
Proof.
  introv u.
  apply dest_nuprl_csname in u.
  unfold per_bar in u; exrepnd.

  eapply eq_term_equals_trans;[eauto|].
  eapply eq_term_equals_trans;[|apply (per_bar_eq_equality_of_csname_bar_lib_per _ bar)].
  apply implies_eq_term_equals_per_bar_eq.
  apply all_in_bar_ext_intersect_bars_same; simpl; auto.
  introv br ext; introv.
  pose proof (u0 _ br _ ext x) as u0; simpl in *.
  unfold per_csname in *; exrepnd; spcast; auto; GC.
  apply computes_to_valc_isvalue_eq in u0; eauto 2 with slow; ginv; auto.
Qed.

Lemma tequality_csname {o} :
  forall lib n, @tequality o lib (mkc_csname n) (mkc_csname n).
Proof.
  introv.
  exists (equality_of_csname_bar lib n).
  apply CL_csname.
  exists n; dands; spcast; eauto 3 with slow.
Qed.
Hint Resolve tequality_csname : slow.

Hint Rewrite @substc2_equality : slow.
Hint Rewrite @mkcv_equality_substc : slow.
Hint Rewrite @mkc_var_substc : slow.

Lemma equality_in_csname {p} :
  forall lib (t1 t2 : @CTerm p) n,
    equality lib t1 t2 (mkc_csname n)
    -> equality_of_csname_bar lib n t1 t2.
Proof.
  unfold equality; introv e; exrepnd.
  apply dest_nuprl_csname2 in e1.
  apply e1 in e0; auto.
Qed.

Lemma implies_equality_natk2nat_bar {o} :
  forall lib (f g : @CTerm o) n,
    all_in_ex_bar
      lib
      (fun lib =>
         forall m,
           m < n
           -> {k : nat
               , ccomputes_to_valc lib (mkc_apply f (mkc_nat m)) (mkc_nat k)
               # ccomputes_to_valc lib (mkc_apply g (mkc_nat m)) (mkc_nat k)})
    -> equality lib f g (natk2nat (mkc_nat n)).
Proof.
  introv imp.
  apply equality_in_fun; dands; eauto 3 with slow.

  { apply type_mkc_natk.
    apply in_ext_implies_all_in_ex_bar; introv x.
    exists (Z.of_nat n); spcast.
    apply computes_to_valc_refl; eauto 3 with slow. }

  introv x e.
  apply equality_in_natk in e; exrepnd; spcast.

  eapply all_in_ex_bar_equality_implies_equality.
  eapply all_in_ex_bar_modus_ponens1;try exact e; clear e; introv y e; exrepnd; spcast.

  eapply equality_respects_cequivc_left;
    [apply implies_ccequivc_ext_apply;
      [apply ccequivc_ext_refl
      |apply ccequivc_ext_sym;
        apply computes_to_valc_implies_ccequivc_ext;
        exact e0]
    |].

  eapply equality_respects_cequivc_right;
    [apply implies_ccequivc_ext_apply;
      [apply ccequivc_ext_refl
      |apply ccequivc_ext_sym;
        apply computes_to_valc_implies_ccequivc_ext;
        exact e2]
    |].

  clear dependent a.
  clear dependent a'.

  apply computes_to_valc_isvalue_eq in e3; eauto 3 with slow.
  rw @mkc_nat_eq in e3; ginv.

  assert (m < n) as ltm by omega.
  clear e1.

  apply equality_in_tnat.
  assert (lib_extends lib'0 lib) as xt by eauto 3 with slow.
  clear dependent lib'.
  eapply lib_extends_preserves_all_in_ex_bar in imp;[|exact xt].
  eapply all_in_ex_bar_modus_ponens1;try exact imp; clear imp; introv ext imp; exrepnd; spcast.
  clear dependent lib.

  pose proof (imp m ltm) as h; exrepnd.
  exists k; dands; spcast; eauto 4 with slow.
Qed.

Lemma implies_member_natk2nat_bar {o} :
  forall lib (f : @CTerm o) n,
    all_in_ex_bar
      lib
      (fun lib =>
         forall m,
           m < n
           -> {k : nat , ccomputes_to_valc lib (mkc_apply f (mkc_nat m)) (mkc_nat k)})
    -> member lib f (natk2nat (mkc_nat n)).
Proof.
  introv imp.
  apply implies_equality_natk2nat_bar.
  eapply all_in_ex_bar_modus_ponens1;try exact imp; clear imp; introv ext imp; exrepnd; spcast.
  introv ltm.
  apply imp in ltm; exrepnd.
  exists k; auto.
Qed.

Lemma name_in_library_implies_entry_in_library {o} :
  forall name (lib : @library o),
    name_in_library name lib
    ->
    exists entry,
      entry_in_library entry lib
      /\ entry2name entry = entry_name_cs name.
Proof.
  induction lib; introv h; simpl in *; tcsp.
  destruct a; simpl in *; repndors; repnd; subst; tcsp; GC.

  - exists (lib_cs name0 entry); simpl; dands; tcsp.

  - autodimp IHlib hyp; exrepnd.
    exists entry0; simpl; dands; tcsp.
    right; dands; tcsp.
    unfold matching_entries; allrw; simpl; auto.

  - autodimp IHlib hyp; exrepnd.
    exists entry; simpl; dands; tcsp.
    right; dands; tcsp.
    unfold matching_entries; allrw; simpl; auto.
Qed.

Lemma is_nat_or_seq_kind_implies_compatible_choice_sequence_name_0 :
  forall name,
    is_nat_or_seq_kind name
    -> compatible_choice_sequence_name 0 name.
Proof.
  introv h; destruct name as [name k]; simpl in *.
  unfold is_nat_or_seq_kind in *; simpl in *.
  unfold compatible_choice_sequence_name; simpl.
  unfold compatible_cs_kind; boolvar; tcsp.
Qed.
Hint Resolve is_nat_or_seq_kind_implies_compatible_choice_sequence_name_0 : slow.

Lemma compatible_choice_sequence_name_0_implies_is_nat_or_seq_kind :
  forall name,
    compatible_choice_sequence_name 0 name
    -> is_nat_or_seq_kind name.
Proof.
  introv h; destruct name as [name k]; simpl in *.
  unfold is_nat_or_seq_kind in *; simpl in *.
  unfold compatible_choice_sequence_name in *; simpl.
  unfold compatible_cs_kind in *; boolvar; tcsp.
Qed.
Hint Resolve compatible_choice_sequence_name_0_implies_is_nat_or_seq_kind : slow.

Hint Resolve entry_in_library_implies_find_cs_some : slow.

Lemma cs_entry_in_library_lawless_upto_implies_length_ge {o} :
  forall (lib lib' : @library o) name k vals restr,
    is_nat_or_seq_kind name
    -> correct_restriction name restr
    -> extend_library_lawless_upto lib lib' name k
    -> entry_in_library (lib_cs name (MkChoiceSeqEntry _ vals restr)) lib
    -> k <= length vals.
Proof.
  induction lib; introv isn cor ext ilib; simpl in *; tcsp.
  destruct lib'; simpl in *; tcsp; repnd.
  repndors; repnd; subst; simpl in *; eauto;[].

  destruct l; simpl in *; tcsp; ginv; boolvar; subst; tcsp; GC.
  destruct restr; tcsp.

  - destruct entry.
    destruct cse_restriction; repnd; exrepnd; subst; ginv;[].
    rewrite length_app; allrw; omega.

  - unfold correct_restriction in *.
    subst.
    unfold is_nat_or_seq_kind in *.
    destruct name0 as [name kd]; simpl in *.
    destruct kd; subst; boolvar; tcsp.
Qed.
Hint Resolve cs_entry_in_library_lawless_upto_implies_length_ge : slow.

Lemma is_nat_mkc_nat {o} :
  forall n i, @is_nat o n (mkc_nat i).
Proof.
  introv; eexists; eauto.
Qed.
Hint Resolve is_nat_mkc_nat : slow.

Lemma cterm_is_nth_implies_is_nat {o} :
  forall (v : @CTerm o) n l,
    cterm_is_nth v n l
    -> is_nat n v.
Proof.
  introv h.
  unfold cterm_is_nth in *; exrepnd; subst; eauto 3 with slow.
Qed.
Hint Resolve cterm_is_nth_implies_is_nat : slow.

Lemma cs_entry_in_library_lawless_upto_implies_is_nat {o} :
  forall (lib lib' : @library o) name k vals restr n v,
    is_nat_or_seq_kind name
    -> correct_restriction name restr
    -> choice_sequence_satisfies_restriction vals restr
    -> extend_library_lawless_upto lib lib' name k
    -> entry_in_library (lib_cs name (MkChoiceSeqEntry _ vals restr)) lib
    -> select n vals = Some v
    -> is_nat n v.
Proof.
  induction lib; introv isn cor sat ext ilib sel; simpl in *; tcsp.
  destruct lib'; simpl in *; tcsp; repnd.
  repndors; repnd; subst; simpl in *; eauto;[].

  clear IHlib ext.

  destruct l; simpl in *; tcsp; ginv; boolvar; subst; tcsp; GC.
  destruct restr; tcsp.

  - destruct entry.
    destruct cse_restriction; repnd; exrepnd; subst; ginv;[].
    unfold correct_restriction in *; simpl in *.
    destruct name0 as [name0 kd]; simpl in *.
    destruct kd; boolvar; tcsp; subst; GC; repnd.

    + apply sat in sel.
      apply cor in sel; auto.

    + apply sat in sel.
      destruct (lt_dec n (length l)) as [dd|dd].

      * apply cor2 in sel; auto.
        eauto 3 with slow.

      * apply cor in sel; auto; try omega.

  - unfold correct_restriction in *.
    subst.
    unfold is_nat_or_seq_kind in *.
    destruct name0 as [name kd]; simpl in *.
    destruct kd; subst; boolvar; tcsp.
Qed.
Hint Resolve cs_entry_in_library_lawless_upto_implies_is_nat : slow.

Lemma extend_library_lawless_upto_implies_exists_nats {o} :
  forall name (lib lib' : @library o) entry k,
    is_nat_or_seq_kind name
    -> entry_in_library entry lib
    -> entry2name entry = entry_name_cs name
    -> safe_library_entry entry
    -> extend_library_lawless_upto lib lib' name k
    -> exists vals restr,
        find_cs lib name = Some (MkChoiceSeqEntry _ vals restr)
        /\ k <= length vals
        /\ forall n v, select n vals = Some v -> is_nat n v.
Proof.
  introv isn ilib eqname safe ext.
  destruct entry; simpl in *; tcsp; ginv;[].
  destruct entry as [vals restr]; simpl in *; repnd.
  exists vals restr.
  dands; eauto 3 with slow.
Qed.

Hint Rewrite Nat2Z.id : slow.

Lemma choice_sequence_vals_extends_implies_select_some {o} :
  forall (vals1 vals2 : @ChoiceSeqVals o) m t,
    choice_sequence_vals_extend vals2 vals1
    -> select m vals1 = Some t
    -> select m vals2 = Some t.
Proof.
  introv h q; unfold choice_sequence_vals_extend in *; exrepnd; subst.
  rewrite select_app_l; eauto 3 with slow.
Qed.

Lemma mkc_choice_seq_in_natk2nat {o} :
  forall (lib : @library o) (name : choice_sequence_name) k,
    is_nat_or_seq_kind name
    -> safe_library lib
    -> member lib (mkc_choice_seq name) (natk2nat (mkc_nat k)).
Proof.
  introv isn safe.
  apply implies_member_natk2nat_bar.

  (* first we need to add the sequence to the library *)
  exists (extend_seq_to_bar lib safe k name isn).

  introv br ext ltm.
  simpl in * |-; exrepnd.
  assert (safe_library lib') as safe' by eauto 3 with slow.
  apply name_in_library_implies_entry_in_library in br2; exrepnd.
  applydup safe' in br2.

  pose proof (extend_library_lawless_upto_implies_exists_nats name lib' lib'' entry k) as q.
  repeat (autodimp q hyp); exrepnd.
  pose proof (q1 m (nth m vals mkc_zero)) as w.
  autodimp w hyp;[apply nth_select1; omega|];[].
  unfold is_nat in w; exrepnd.
  assert (select m vals = Some (mkc_nat i)) as xx.
  { eapply nth_select3; eauto; unfold ChoiceSeqVal in *; try omega. }

  exists i.
  spcast.
  unfold computes_to_valc; simpl.
  split; eauto 3 with slow.
  eapply reduces_to_if_split2;[csunf; simpl; reflexivity|].
  apply reduces_to_if_step.
  csunf; simpl.
  unfold compute_step_eapply; simpl; boolvar; try omega;[].
  autorewrite with slow.

  eapply lib_extends_preserves_find_cs in q0;[|eauto].
  exrepnd; simpl in *.
  destruct entry2; simpl in *.
  unfold find_cs_value_at.
  allrw;simpl.
  rewrite find_value_of_cs_at_is_select.
  erewrite choice_sequence_vals_extends_implies_select_some; eauto; simpl; auto.
Qed.


Lemma equality_in_csname_implies_equality_in_natk2nat {o} :
  forall lib (a b t : @CTerm o) k,
    safe_library lib
    -> computes_to_valc lib t (mkc_nat k)
    -> equality lib a b (mkc_csname 0)
    -> equality lib a b (natk2nat t).
Proof.
  introv safe comp ecs.
  apply equality_in_csname in ecs.

  apply all_in_ex_bar_equality_implies_equality.
  eapply all_in_ex_bar_modus_ponens1;[|exact ecs]; clear ecs; introv y ecs; exrepnd; spcast.
  eapply lib_extends_preserves_computes_to_valc in comp;[|eauto].
  assert (safe_library lib') as safe' by eauto 3 with slow.
  clear lib y safe.
  rename lib' into lib.

  unfold equality_of_csname in ecs; exrepnd; spcast.

  eapply cequivc_preserving_equality;
    [|apply ccequivc_ext_sym; introv x; spcast;
      apply implies_cequivc_natk2nat;
      apply computes_to_valc_implies_cequivc; eauto 3 with slow].
  eapply equality_respects_cequivc_left;
    [apply ccequivc_ext_sym; introv x; spcast;
     apply computes_to_valc_implies_cequivc; eauto 3 with slow|].
  eapply equality_respects_cequivc_right;
    [apply ccequivc_ext_sym; introv x; spcast;
     apply computes_to_valc_implies_cequivc; eauto 3 with slow|].

  rw @member_eq.
  clear dependent a.
  clear dependent b.
  clear dependent t.
  apply mkc_choice_seq_in_natk2nat; eauto 3 with slow.
Qed.



(**

<<
   H |- ∀ (n ∈ ℕ) (f ∈ ℕn→ℕ). ∃ (a:Free). f = a ∈ ℕn→ℕ

     By LS1
>>

 *)

(* Write a proper extract instead of axiom *)
Definition rule_ls1 {o}
           (lib   : @library o)
           (name  : choice_sequence_name)
           (n f a : NVar)
           (H     : @bhyps o) :=
  mk_rule
    (mk_baresequent H (mk_concl (ls1 n f a) (ls1_extract name n f)))
    []
    [].

Lemma rule_ls1_true {o} :
  forall lib (name : choice_sequence_name) (n f a : NVar) (H : @bhyps o)
         (d1 : n <> f) (d2 : n <> a) (d3 : a <> f) (safe : safe_library lib),
    rule_true lib (rule_ls1 lib name n f a H).
Proof.
  unfold rule_ls1, rule_true, closed_type_baresequent, closed_extract_baresequent; simpl.
  intros.
  clear cargs.

  (* We prove the well-formedness of things *)
  destseq; allsimpl.
  dLin_hyp; exrepnd.

  assert (@covered o (ls1_extract name n f) (nh_vars_hyps H)) as cv.
  { dwfseq; tcsp. }
  exists cv.

  (* pick a fresh choice sequence name, and define a constraint based on [hyp1] and [hyp2] *)

  vr_seq_true.
  autorewrite with slow.
  dands.

  - apply tequality_function; dands; eauto 3 with slow.
    introv xt ea.

    eapply lib_extends_preserves_similarity in sim;[|eauto].
    eapply lib_extends_preserves_hyps_functionality_ext in eqh;[|eauto].
    assert (safe_library lib'0) as safe' by eauto 3 with slow.
    clear lib lib' ext xt safe.
    rename lib'0 into lib; rename safe' into safe.

    repeat (rewrite substc_mkcv_function;[|auto];[]).

    apply equality_in_tnat in ea.
    apply all_in_ex_bar_tequality_implies_tequality.
    eapply all_in_ex_bar_modus_ponens1;[|exact ea]; clear ea; introv y ea; exrepnd; spcast.

    eapply lib_extends_preserves_similarity in sim;[|eauto].
    eapply lib_extends_preserves_hyps_functionality_ext in eqh;[|eauto].
    assert (safe_library lib') as safe' by eauto 3 with slow.
    clear lib y safe.
    rename lib' into lib; rename safe' into safe.

    unfold equality_of_nat in ea; exrepnd; spcast.

    eapply tequality_respects_alphaeqc_left;
      [apply alphaeqc_sym; apply implies_alphaeqc_mk_function;
       apply subst_ls1_cond1; auto|];[].
    eapply tequality_respects_alphaeqc_right;
      [apply alphaeqc_sym; apply implies_alphaeqc_mk_function;
       apply subst_ls1_cond1; auto|];[].

    apply tequality_function; dands; eauto 3 with slow.

    {
      eapply tequality_respects_alphaeqc_left;
        [apply alphaeqc_sym; apply substc_mkcv_natk2nat|].
      eapply tequality_respects_alphaeqc_right;
        [apply alphaeqc_sym; apply substc_mkcv_natk2nat|].
      autorewrite with slow.
      eapply tequality_respects_cequivc_left;
        [apply ccequivc_ext_sym; introv z; spcast; apply implies_cequivc_natk2nat;
         apply computes_to_valc_implies_cequivc;eauto 3 with slow|].
      eapply tequality_respects_cequivc_right;
        [apply ccequivc_ext_sym; introv z; spcast; apply implies_cequivc_natk2nat;
         apply computes_to_valc_implies_cequivc;eauto 3 with slow|].
      eauto 3 with slow.
    }

    introv xt ef.

    eapply lib_extends_preserves_similarity in sim;[|eauto].
    eapply lib_extends_preserves_hyps_functionality_ext in eqh;[|eauto].
    eapply lib_extends_preserves_computes_to_valc in ea1;[|eauto].
    eapply lib_extends_preserves_computes_to_valc in ea0;[|eauto].
    assert (safe_library lib') as safe' by eauto 3 with slow.
    clear lib xt safe.
    rename lib' into lib; rename safe' into safe.

    eapply alphaeqc_preserving_equality in ef;[|apply substc_mkcv_natk2nat].
    autorewrite with slow in *.
    apply tequality_mkc_squash.

    repeat (rewrite mkcv_exists_substc; auto;[]).
    autorewrite with slow.
    apply tequality_product; dands; eauto 3 with slow.

    introv xt ecs.

    eapply lib_extends_preserves_similarity in sim;[|eauto].
    eapply lib_extends_preserves_hyps_functionality_ext in eqh;[|eauto].
    eapply lib_extends_preserves_computes_to_valc in ea1;[|eauto].
    eapply lib_extends_preserves_computes_to_valc in ea0;[|eauto].
    eapply equality_monotone in ef;[|eauto].
    assert (safe_library lib') as safe' by eauto 3 with slow.
    clear lib xt safe.
    rename lib' into lib; rename safe' into safe.

    autorewrite with slow.
    repeat (rewrite substc2_mk_cv_app_r; auto;[]).
    autorewrite with slow.

    apply tequality_mkc_equality_if_equal; eauto 3 with slow.

    {
      eapply tequality_respects_cequivc_left;
        [apply ccequivc_ext_sym; introv z; spcast; apply implies_cequivc_natk2nat;
         apply computes_to_valc_implies_cequivc;eauto 3 with slow|].
      eapply tequality_respects_cequivc_right;
        [apply ccequivc_ext_sym; introv z; spcast; apply implies_cequivc_natk2nat;
         apply computes_to_valc_implies_cequivc;eauto 3 with slow|].
      eauto 3 with slow.
    }

    eapply equality_in_csname_implies_equality_in_natk2nat; eauto.

  -
Qed.
