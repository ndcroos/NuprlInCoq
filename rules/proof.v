(*

  Copyright 2014 Cornell University
  Copyright 2015 Cornell University
  Copyright 2016 Cornell University

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


  Websites: http://nuprl.org/html/Nuprl2Coq
            https://github.com/vrahli/NuprlInCoq

  Authors: Vincent Rahli

*)


Require Export rules_isect.
Require Export rules_squiggle.
Require Export rules_squiggle2.
Require Export rules_squiggle3.
Require Export rules_squiggle5.
Require Export rules_squiggle6.
Require Export rules_squiggle7.
Require Export rules_false.
Require Export rules_struct.
Require Export rules_function.

Require Export computation_preserves_lib.


Inductive valid_rule {o} : @rule o -> Type :=
| valid_rule_isect_equality :
    forall a1 a2 b1 b2 x1 x2 y i H,
      !LIn y (vars_hyps H)
      -> valid_rule (rule_isect_equality a1 a2 b1 b2 x1 x2 y i H).

Inductive gen_proof {o} (G : @baresequent o) : Type :=
| gen_proof_cons :
    forall hyps args,
      valid_rule (mk_rule G hyps args)
      -> (forall h, LIn h hyps -> gen_proof h)
      -> gen_proof G.

(* [pwf_sequent] says that the hypotheses and conclusion are well-formed and
   the type is closed w.r.t. the hypotheses.
 *)
Lemma valid_gen_proof {o} :
  forall lib (seq : @baresequent o) (wf : pwf_sequent seq),
    gen_proof seq -> sequent_true2 lib seq.
Proof.
  introv wf p.
  induction p as [? ? ? vr imp ih].
  inversion vr as [a1 a2 b1 b2 x1 x2 y i hs niy]; subst; allsimpl; clear vr.

  - apply (rule_isect_equality_true2 lib y i a1 a2 b1 b2 x1 x2 hs); simpl; tcsp.

    + unfold args_constraints; simpl; introv h; repndors; subst; tcsp.

    + introv e; repndors; subst; tcsp.

      * apply ih; auto.
        apply (rule_isect_equality_wf y i a1 a2 b1 b2 x1 x2 hs); simpl; tcsp.

      * apply ih; auto.
        apply (rule_isect_equality_wf y i a1 a2 b1 b2 x1 x2 hs); simpl; tcsp.
Qed.

Definition NVin v (vs : list NVar) := memvar v vs = false.

Definition Vin v (vs : list NVar) := memvar v vs = true.

Lemma NVin_iff :
  forall v vs, NVin v vs <=> !LIn v vs.
Proof.
  introv.
  unfold NVin.
  rw <- (@assert_memberb NVar eq_var_dec).
  rw <- not_of_assert; sp.
Qed.

Lemma Vin_iff :
  forall v vs, Vin v vs <=> LIn v vs.
Proof.
  introv.
  unfold Vin.
  rw <- (@assert_memberb NVar eq_var_dec); auto.
Qed.

Inductive Llist {A} (f : A -> Type) : list A -> Type :=
| lnil : Llist f []
| lcons : forall {h t}, (f h) -> Llist f t -> Llist f (h :: t).

Lemma in_Llist {A} :
  forall f (a : A) l,
    LIn a l -> Llist f l -> f a.
Proof.
  induction l; introv i h; allsimpl; tcsp.
  repndors; subst; auto.
  - inversion h; subst; auto.
  - apply IHl; auto.
    inversion h; subst; auto.
Qed.

Lemma Llist_implies_forall {A f} {l : list A} :
  Llist f l -> (forall v, LIn v l -> f v).
Proof.
  introv h i.
  eapply in_Llist in h;eauto.
Qed.

Definition ProofName := opname.
Definition ProofNames := list ProofName.

(*
Record ProofLibSig {o} lib :=
  {
    ProofLib_type : Type;
    ProofLib_access :
      ProofLib_type
      -> ProofName
      -> option {seq : @baresequent o &  sequent_true2 lib seq}
  }.
*)

Record ProofContext {o} :=
  MkProofContext
    {
      PC_lib :> @library o;
      PC_proof_names : ProofNames
    }.

Inductive proof {o} ctxt : @baresequent o -> Type :=
| proof_from_lib :
    forall name seq,
      LIn name (@PC_proof_names o ctxt)
      -> proof ctxt seq
| proof_isect_eq :
    forall a1 a2 b1 b2 e1 e2 x1 x2 y i H,
      NVin y (vars_hyps H)
      -> proof ctxt (rule_isect_equality2_hyp1 a1 a2 e1 i H)
      -> proof ctxt (rule_isect_equality2_hyp2 a1 b1 b2 e2 x1 x2 y i H)
      -> proof ctxt (rule_isect_equality_concl a1 a2 x1 x2 b1 b2 i H)
| proof_approx_refl :
    forall a H,
      proof ctxt (rule_approx_refl_concl a H)
| proof_cequiv_approx :
    forall a b e1 e2 H,
      proof ctxt (rule_cequiv_approx2_hyp a b e1 H)
      -> proof ctxt (rule_cequiv_approx2_hyp b a e2 H)
      -> proof ctxt (rule_cequiv_approx_concl a b H)
| proof_approx_eq :
    forall a1 a2 b1 b2 e1 e2 i H,
      proof ctxt (rule_eq_base2_hyp a1 a2 e1 H)
      -> proof ctxt (rule_eq_base2_hyp b1 b2 e2 H)
      -> proof ctxt (rule_approx_eq_concl a1 a2 b1 b2 i H)
| proof_cequiv_eq :
    forall a1 a2 b1 b2 e1 e2 i H,
      proof ctxt (rule_eq_base2_hyp a1 a2 e1 H)
      -> proof ctxt (rule_eq_base2_hyp b1 b2 e2 H)
      -> proof ctxt (rule_cequiv_eq_concl a1 a2 b1 b2 i H)
| proof_bottom_diverges :
    forall x H J,
      proof ctxt (rule_bottom_diverges_concl x H J)
| proof_cut :
    forall B C t u x H,
      wf_term B
      -> covered B (vars_hyps H)
      -> NVin x (vars_hyps H)
      -> proof ctxt (rule_cut_hyp1 H B u)
      -> proof ctxt (rule_cut_hyp2 H x B C t)
      -> proof ctxt (rule_cut_concl H C t x u)
| proof_equal_in_base :
    forall a b e F H,
      proof ctxt (rule_equal_in_base2_hyp1 a b e H)
      -> (forall v (i : LIn v (free_vars a)),
             proof ctxt (rule_equal_in_base2_hyp2 v (F v i) H))
      -> proof ctxt (rule_equal_in_base_concl a b H)
| proof_hypothesis :
    forall x A G J,
      proof ctxt (rule_hypothesis_concl G J A x)
| proof_cequiv_subst_concl :
    forall C x a b t e H,
      wf_term a
      -> wf_term b
      -> covered a (vars_hyps H)
      -> covered b (vars_hyps H)
      -> proof ctxt (rule_cequiv_subst_hyp1 H x C b t)
      -> proof ctxt (rule_cequiv_subst2_hyp2 H a b e)
      -> proof ctxt (rule_cequiv_subst_hyp1 H x C a t)
| proof_approx_member_eq :
    forall a b e H,
      proof ctxt (rule_approx_member_eq2_hyp a b e H)
      -> proof ctxt (rule_approx_member_eq_concl a b H)
| proof_cequiv_computation :
    forall a b H,
      reduces_to ctxt a b
      -> proof ctxt (rule_cequiv_concl a b H)
| proof_function_elimination :
    (* When deriving a sequent, e is not supposed to be given but inferred
     * from the second sequent.  That's the case in a pre_proof
     *)
    forall A B C a e ea f x z H J,
      wf_term a
      -> covered a (snoc (vars_hyps H) f ++ vars_hyps J)
      -> !LIn z (vars_hyps H)
      -> !LIn z (vars_hyps J)
      -> z <> f
      -> proof ctxt (rule_function_elimination_hyp1 A B a ea f x H J)
      -> proof ctxt (rule_function_elimination_hyp2 A B C a e f x z H J)
      -> proof ctxt (rule_function_elimination_concl A B C e f x z H J).

Inductive pre_conclusion {o} :=
| pre_concl_ext : forall (ctype : @NTerm o), pre_conclusion
| pre_concl_typ : forall (ctype : @NTerm o), pre_conclusion.

Definition mk_pre_concl {o} (t : @NTerm o) : pre_conclusion :=
  pre_concl_ext t.

Definition mk_pre_concleq {o} (t1 t2 T : @NTerm o) : pre_conclusion :=
  mk_pre_concl (mk_equality t1 t2 T).

Record pre_baresequent {p} :=
  MkPreBaresequent
    {
      pre_hyps  : @barehypotheses p;
      pre_concl : @pre_conclusion p
    }.

Definition mk_pre_bseq {o} H (c : @pre_conclusion o) : pre_baresequent :=
  MkPreBaresequent o H c.

Definition pre_rule_isect_equality_concl {o} a1 a2 x1 x2 b1 b2 i (H : @bhyps o) :=
  mk_pre_bseq
    H
    (mk_pre_concleq
       (mk_isect a1 x1 b1)
       (mk_isect a2 x2 b2)
       (mk_uni i)).

Definition pre_rule_isect_equality_hyp1 {o} a1 a2 i (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concleq a1 a2 (mk_uni i)).

Definition pre_rule_isect_equality_hyp2 {o} a1 b1 b2 x1 x2 y i (H : @bhyps o) :=
  mk_pre_bseq
    (snoc H (mk_hyp y a1))
    (mk_pre_concleq
       (subst b1 x1 (mk_var y))
       (subst b2 x2 (mk_var y))
       (mk_uni i)).

Definition pre_rule_cequiv_concl {o} a b (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concl (mk_cequiv a b)).

Definition pre_rule_function_elimination_concl {o}
           (A : @NTerm o) B C f x H J :=
  mk_pre_bseq
    (snoc H (mk_hyp f (mk_function A x B)) ++ J)
    (mk_pre_concl C).

Definition pre_rule_function_elimination_hyp1 {o}
           (A : @NTerm o) B a f x H J :=
  mk_pre_bseq
    (snoc H (mk_hyp f (mk_function A x B)) ++ J)
    (mk_pre_concl (mk_member a A)).

Definition pre_rule_function_elimination_hyp2 {o}
           (A : @NTerm o) B C a f x z H J :=
  mk_pre_bseq
    (snoc (snoc H (mk_hyp f (mk_function A x B)) ++ J)
          (mk_hyp z (mk_member (mk_apply (mk_var f) a)
                               (subst B x a))))
    (mk_pre_concl C).

Definition pre_rule_approx_refl_concl {o} a (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concl (mk_approx a a)).

Definition pre_rule_cequiv_approx_concl {o} (a b : @NTerm o) H :=
  mk_pre_bseq H (mk_pre_concl (mk_cequiv a b)).

Definition pre_rule_cequiv_approx_hyp {o} (a b : @NTerm o) H :=
  mk_pre_bseq H (mk_pre_concl (mk_approx a b)).

Definition pre_rule_approx_eq_concl {o} a1 a2 b1 b2 i (H : @bhyps o) :=
  mk_pre_bseq
    H
    (mk_pre_concleq
       (mk_approx a1 b1)
       (mk_approx a2 b2)
       (mk_uni i)).

Definition pre_rule_eq_base_hyp {o} a1 a2 (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concleq a1 a2 mk_base).

Definition pre_rule_cequiv_eq_concl {o} a1 a2 b1 b2 i (H : @bhyps o) :=
  mk_pre_bseq
    H
    (mk_pre_concleq
       (mk_cequiv a1 b1)
       (mk_cequiv a2 b2)
       (mk_uni i)).

Definition pre_rule_bottom_diverges_concl {o} x (H J : @bhyps o) :=
  mk_pre_bseq
    (snoc H (mk_hyp x (mk_halts mk_bottom)) ++ J)
    (mk_pre_concl mk_false).

Definition pre_rule_cut_concl {o} (H : @bhyps o) C :=
  mk_pre_bseq H (mk_pre_concl C).

Definition pre_rule_cut_hyp1 {o} (H : @bhyps o) B :=
  mk_pre_bseq H (mk_pre_concl B).

Definition pre_rule_cut_hyp2 {o} (H : @bhyps o) x B C :=
  mk_pre_bseq (snoc H (mk_hyp x B)) (mk_pre_concl C).

Definition pre_rule_equal_in_base_concl {o} (a b : @NTerm o) H :=
  mk_pre_bseq H (mk_pre_concl (mk_equality a b mk_base)).

Definition pre_rule_equal_in_base_hyp1 {o} (a b : @NTerm o) H :=
  mk_pre_bseq H (mk_pre_concl (mk_cequiv a b)).

Definition pre_rule_equal_in_base_hyp2 {o} (v : NVar) (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concl (mk_member (mk_var v) mk_base)).

Definition pre_rule_equal_in_base_rest {o} (a : @NTerm o) (H : @bhyps o) :=
  map (fun v => pre_rule_equal_in_base_hyp2 v H)
      (free_vars a).

Definition pre_rule_cequiv_subst_hyp1 {o} (H : @bhyps o) x C a :=
  mk_pre_bseq H (mk_pre_concl (subst C x a)).

Definition pre_rule_cequiv_subst_hyp2 {o} (H : @bhyps o) a b :=
  mk_pre_bseq H (mk_pre_concl (mk_cequiv a b)).

Definition pre_rule_hypothesis_concl {o} (G J : @bhyps o) A x :=
  mk_pre_bseq (snoc G (mk_hyp x A) ++ J) (mk_pre_concl A).

Definition pre_rule_approx_member_eq_concl {o} a b (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concleq mk_axiom mk_axiom (mk_approx a b)).

Definition pre_rule_approx_member_eq_hyp {o} a b (H : @bhyps o) :=
  mk_pre_bseq H (mk_pre_concl (mk_approx a b)).

(* A pre-proof is a proof without the extracts, which we can build a posteriori *)
Inductive pre_proof {o} (hole : bool) ctxt : @pre_baresequent o -> Type :=
| pre_proof_from_lib :
    forall name seq,
      LIn name (@PC_proof_names o ctxt)
      -> pre_proof hole ctxt seq
| pre_proof_hole : forall s, hole = true -> pre_proof hole ctxt s
| pre_proof_isect_eq :
    forall a1 a2 b1 b2 x1 x2 y i H,
      NVin y (vars_hyps H)
      -> pre_proof hole ctxt (pre_rule_isect_equality_hyp1 a1 a2 i H)
      -> pre_proof hole ctxt (pre_rule_isect_equality_hyp2 a1 b1 b2 x1 x2 y i H)
      -> pre_proof hole ctxt (pre_rule_isect_equality_concl a1 a2 x1 x2 b1 b2 i H)
| pre_proof_approx_refl :
    forall a H,
      pre_proof hole ctxt (pre_rule_approx_refl_concl a H)
| pre_proof_cequiv_approx :
    forall a b H,
      pre_proof hole ctxt (pre_rule_cequiv_approx_hyp a b H)
      -> pre_proof hole ctxt (pre_rule_cequiv_approx_hyp b a H)
      -> pre_proof hole ctxt (pre_rule_cequiv_approx_concl a b H)
| pre_proof_approx_eq :
    forall a1 a2 b1 b2 i H,
      pre_proof hole ctxt (pre_rule_eq_base_hyp a1 a2 H)
      -> pre_proof hole ctxt (pre_rule_eq_base_hyp b1 b2 H)
      -> pre_proof hole ctxt (pre_rule_approx_eq_concl a1 a2 b1 b2 i H)
| pre_proof_cequiv_eq :
    forall a1 a2 b1 b2 i H,
      pre_proof hole ctxt (pre_rule_eq_base_hyp a1 a2 H)
      -> pre_proof hole ctxt (pre_rule_eq_base_hyp b1 b2 H)
      -> pre_proof hole ctxt (pre_rule_cequiv_eq_concl a1 a2 b1 b2 i H)
| pre_proof_bottom_diverges :
    forall x H J,
      pre_proof hole ctxt (pre_rule_bottom_diverges_concl x H J)
| pre_proof_cut :
    forall B C x H,
      wf_term B
      -> covered B (vars_hyps H)
      -> NVin x (vars_hyps H)
      -> pre_proof hole ctxt (pre_rule_cut_hyp1 H B)
      -> pre_proof hole ctxt (pre_rule_cut_hyp2 H x B C)
      -> pre_proof hole ctxt (pre_rule_cut_concl H C)
| pre_proof_equal_in_base :
    forall a b H,
      pre_proof hole ctxt (pre_rule_equal_in_base_hyp1 a b H)
      -> (forall v, LIn v (free_vars a) -> pre_proof hole ctxt (pre_rule_equal_in_base_hyp2 v H))
      -> pre_proof hole ctxt (pre_rule_equal_in_base_concl a b H)
| pre_proof_hypothesis :
    forall x A G J,
      pre_proof hole ctxt (pre_rule_hypothesis_concl G J A x)
| pre_proof_cequiv_subst_concl :
    forall C x a b H,
      wf_term a
      -> wf_term b
      -> covered a (vars_hyps H)
      -> covered b (vars_hyps H)
      -> pre_proof hole ctxt (pre_rule_cequiv_subst_hyp1 H x C b)
      -> pre_proof hole ctxt (pre_rule_cequiv_subst_hyp2 H a b)
      -> pre_proof hole ctxt (pre_rule_cequiv_subst_hyp1 H x C a)
| pre_proof_approx_member_eq :
    forall a b H,
      pre_proof hole ctxt (pre_rule_approx_member_eq_hyp a b H)
      -> pre_proof hole ctxt (pre_rule_approx_member_eq_concl a b H)
| pre_proof_cequiv_computation :
    forall a b H,
      reduces_to ctxt a b
      -> pre_proof hole ctxt (pre_rule_cequiv_concl a b H)
| pre_proof_function_elimination :
    forall A B C a f x z H J,
      wf_term a
      -> covered a (snoc (vars_hyps H) f ++ vars_hyps J)
      -> !LIn z (vars_hyps H)
      -> !LIn z (vars_hyps J)
      -> z <> f
      -> pre_proof hole ctxt (pre_rule_function_elimination_hyp1 A B a f x H J)
      -> pre_proof hole ctxt (pre_rule_function_elimination_hyp2 A B C a f x z H J)
      -> pre_proof hole ctxt (pre_rule_function_elimination_concl A B C f x H J).

Definition PreStatement {o} (T : @NTerm o) : pre_baresequent :=
  mk_pre_bseq [] (mk_pre_concl T).

Definition Statement {o} (T : @NTerm o) (e : NTerm) : baresequent :=
  mk_baresequent [] (mk_concl T e).

Definition option2list {T} (x : option T) : list T :=
  match x with
  | Some t => [t]
  | None => []
  end.

Definition opname2opabs (op : opname) : opabs :=
  mk_opabs op [] [].

(* !!MOVE *)
Lemma soterm2nterm_nterm2soterm {o} :
  forall (t : @NTerm o), soterm2nterm (nterm2soterm t) = t.
Proof.
  nterm_ind t as [v|f ind|op bs ind] Case; simpl; auto.
  Case "oterm".
  f_equal.
  rewrite map_map; unfold compose.
  apply eq_map_l; introv i.
  destruct x as [vs t]; simpl.
  f_equal.
  eapply ind; eauto.
Qed.
Hint Rewrite @soterm2nterm_nterm2soterm : slow.

(* !!MOVE *)
Lemma injective_fun_var2sovar : injective_fun var2sovar.
Proof.
  introv e.
  destruct a1, a2.
  unfold var2sovar in e; ginv; auto.
Qed.
Hint Resolve injective_fun_var2sovar : slow.

(* !!MOVE *)
Lemma so_free_vars_nterm2soterm {o} :
  forall (t : @NTerm o),
    so_free_vars (nterm2soterm t)
    = vars2sovars (free_vars t).
Proof.
  nterm_ind t as [v|f ind|op bs ind] Case; simpl; auto.
  rewrite flat_map_map; unfold compose.
  unfold vars2sovars.
  rewrite map_flat_map; unfold compose.
  apply eq_flat_maps; introv i.
  destruct x as [vs t]; simpl.
  rewrite (ind t vs); auto.
  unfold remove_so_vars.
  unfold vars2sovars.
  rewrite <- (map_diff_commute deq_nvar); eauto 2 with slow.
Qed.

Lemma get_utokens_so_nterm2soterm {o} :
  forall (t : @NTerm o),
    get_utokens_so (nterm2soterm t) = get_utokens t.
Proof.
  nterm_ind t as [v|f ind|op bs ind] Case; simpl; auto.
  f_equal.
  rewrite flat_map_map; unfold compose.
  apply eq_flat_maps; introv i.
  destruct x as [vs t]; simpl.
  eapply ind; eauto.
Qed.

Lemma extract2correct {o} :
  forall (t  : @NTerm o)
         (w  : wf_term t)
         (c  : closed t)
         (n  : noutokens t)
         (op : opname),
    correct_abs (opname2opabs op) [] (nterm2soterm t).
Proof.
  introv w c n; introv.
  unfold correct_abs; simpl.
  dands.
  - unfold wf_soterm.
    rewrite soterm2nterm_nterm2soterm; auto.
  - unfold socovered; simpl.
    rewrite so_free_vars_nterm2soterm.
    rewrite c; simpl; auto.
  - constructor.
  - unfold no_utokens.
    rewrite get_utokens_so_nterm2soterm.
    rewrite n; auto.
Qed.

Inductive proof_library_entry {o} lib :=
| PLE_tmp :
    forall (name : ProofName)
           (stmt : @NTerm o)
           (hole : bool),
      pre_proof hole lib (PreStatement stmt)
      -> proof_library_entry lib
| PLE_final :
    forall (name : ProofName)
           (stmt : @NTerm o)
           (ext  : NTerm),
      proof lib (Statement stmt ext)
      -> proof_library_entry lib.

(* proof name *)
Definition PLE_name {o} {lib} (ple : @proof_library_entry o lib) : ProofName :=
  match ple with
  | PLE_tmp name _ _ _ => name
  | PLE_final name _ _ _ => name
  end.

(* only for final proofs *)
Definition PLE_fname {o} {lib} (ple : @proof_library_entry o lib) : option ProofName :=
  match ple with
  | PLE_tmp name _ _ _ => None
  | PLE_final name _ _ _ => Some name
  end.

Definition PLE_extract {o} {lib} (ple : @proof_library_entry o lib) : option NTerm :=
  match ple with
  | PLE_tmp _ _ _ _ => None
  | PLE_final _ _ ext _ => Some ext
  end.

Definition PLE2def {o} {lib} (ple : @proof_library_entry o lib) : option library_entry :=
  match ple with
  | PLE_tmp _ _ _ _ => None
  | PLE_final name stmt ext p =>
    Some (lib_abs (opname2opabs name) [] (nterm2soterm ext) correct)
  end.

Inductive Library {o} :
  @library o    (* list of abstractions       *)
  -> ProofNames (* names of unfinished proofs *)
  -> ProofNames (* names of finished proofs   *)
  -> Type :=
| Library_Empty :
    Library [] [] []
| Library_Abs :
    forall {lib unames fnames}
           (c : Library lib unames fnames)
           (e : @library_entry o)
           (n : assert (isInr (in_lib_dec (opabs_of_lib_entry e) lib))),
      Library (e :: lib) unames fnames
| Library_Proof :
    forall {lib names}
           (c  : Library lib names)
           (p  : proof_library_entry (MkProofContext o lib names))
           (n1 : !LIn (PLE_name p) names)
           (n2 : assert (isInr (in_lib_dec  lib))),
      Library (option2list (PLE_extract p) ++ lib) (option2list (PLE_fname p) ++ names).

(* By assuming [wf_bseq seq], when we start with a sequent with no hypotheses,
   it means that we have to prove that the conclusion is well-formed and closed.
 *)
Lemma valid_proof {o} :
  forall lib (seq : @baresequent o) (wf : wf_bseq seq),
    proof lib seq -> sequent_true2 lib seq.
Proof.
  introv wf p.
  induction p
    as [ (* proved sequent       *) name seq p
       | (* isect_eq             *) a1 a2 b1 b2 e1 e2 x1 x2 y i hs niy p1 ih1 p2 ih2
       | (* approx_refl          *) a hs
       | (* cequiv_approx        *) a b e1 e2 hs p1 ih1 p2 ih2
       | (* approx_eq            *) a1 a2 b1 b2 e1 e2 i hs p1 ih1 p2 ih2
       | (* cequiv_eq            *) a1 a2 b1 b2 e1 e2 i hs p1 ih1 p2 ih2
       | (* bottom_diverges      *) x hs js
       | (* cut                  *) B C t u x hs wB covB nixH p1 ih1 p2 ih2
       | (* equal_in_base        *) a b e F H p1 ih1 ps ihs
       | (* hypothesis           *) x A G J
       | (* cequiv_subst_concl   *) C x a b t e H wfa wfb cova covb p1 ih1 p2 ih2
       | (* approx_member_eq     *) a b e H p ih
       | (* cequiv_computation   *) a b H p ih
       | (* function elimination *) A B C a e ea f x z H J wa cova nizH nizJ dzf p1 ih1 p2 ih2
       ];
    allsimpl;
    allrw NVin_iff.

  - exact p.

  - apply (rule_isect_equality2_true3 lib a1 a2 b1 b2 e1 e2 x1 x2 y i hs); simpl; tcsp.

    + unfold args_constraints; simpl; introv h; repndors; subst; tcsp.

    + introv e; repndors; subst; tcsp.

      * apply ih1; auto.
        apply (rule_isect_equality2_wf2 y i a1 a2 b1 b2 e1 e2 x1 x2 hs); simpl; tcsp.

      * apply ih2; auto.
        apply (rule_isect_equality2_wf2 y i a1 a2 b1 b2 e1 e2 x1 x2 hs); simpl; tcsp.

  - apply (rule_approx_refl_true3 lib hs a); simpl; tcsp.

  - apply (rule_cequiv_approx2_true3 lib hs a b e1 e2); simpl; tcsp.
    introv xx; repndors; subst; tcsp.

    apply ih2; auto.
    apply (rule_cequiv_approx2_wf2 a b e1 e2 hs); simpl; tcsp.

  - apply (rule_approx_eq2_true3 lib a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.
    introv xx; repndors; subst; tcsp.

    + apply ih1; auto.
      apply (rule_approx_eq2_wf2 a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.

    + apply ih2; auto.
      apply (rule_approx_eq2_wf2 a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.

  - apply (rule_cequiv_eq2_true3 lib a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.
    introv xx; repndors; subst; tcsp.

    + apply ih1; auto.
      apply (rule_cequiv_eq2_wf2 a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.

    + apply ih2; auto.
      apply (rule_cequiv_eq2_wf2 a1 a2 b1 b2 e1 e2 i hs); simpl; tcsp.

  - apply (rule_bottom_diverges_true3 lib x hs js); simpl; tcsp.

  - apply (rule_cut_true3 lib hs B C t u x); simpl; tcsp.

    + unfold args_constraints; simpl; introv xx; repndors; subst; tcsp.

    + introv xx; repndors; subst; tcsp.

      * apply ih1.
        apply (rule_cut_wf2 hs B C t u x); simpl; tcsp.

      * apply ih2.
        apply (rule_cut_wf2 hs B C t u x); simpl; tcsp.

  - apply (rule_equal_in_base2_true3 lib H a b e F); simpl; tcsp.

    introv xx; repndors; subst; tcsp.
    unfold rule_equal_in_base2_rest in xx; apply in_mapin in xx; exrepnd; subst.
    pose proof (ihs a0 i) as hh; clear ihs.
    repeat (autodimp hh hyp).
    pose proof (rule_equal_in_base2_wf2 H a b e F) as w.
    apply w; simpl; tcsp.
    right.
    apply in_mapin; eauto.

  - apply (rule_hypothesis_true3 lib); simpl; tcsp.

  - apply (rule_cequiv_subst_concl2_true3 lib H x C a b t e); allsimpl; tcsp.

    introv i; repndors; subst; allsimpl; tcsp.

    + apply ih1.
      apply (rule_cequiv_subst_concl2_wf2 H x C a b t e); simpl; tcsp.

    + apply ih2.
      apply (rule_cequiv_subst_concl2_wf2 H x C a b t e); simpl; tcsp.

  - apply (rule_approx_member_eq2_true3 lib a b e); simpl; tcsp.
    introv xx; repndors; subst; tcsp.
    apply ih.
    apply (rule_approx_member_eq2_wf2 a b e H); simpl; tcsp.

  - apply (rule_cequiv_computation_true3 lib); simpl; tcsp.

  - apply (rule_function_elimination_true3 lib A B C a e ea f x z); simpl; tcsp.

    introv ih; repndors; subst; tcsp.

    + apply ih1.
      pose proof (rule_function_elimination_wf2 A B C a e ea f x z H J) as h.
      unfold wf_rule2, wf_subgoals2 in h; simpl in h.
      repeat (autodimp h hyp).

    + apply ih2.
      pose proof (rule_function_elimination_wf2 A B C a e ea f x z H J) as h.
      unfold wf_rule2, wf_subgoals2 in h; simpl in h.
      repeat (autodimp h hyp).
Qed.

Fixpoint map_option
         {T U : Type}
         (f : T -> option U)
         (l : list T) : option (list U) :=
  match l with
  | [] => Some []
  | t :: ts =>
    match f t, map_option f ts with
    | Some u, Some us => Some (u :: us)
    | _, _ => None
    end
  end.

Fixpoint map_option_in
         {T U : Type}
         (l : list T)
  : forall (f : forall (t : T) (i : LIn t l), option U), option (list U) :=
  match l with
  | [] => fun f => Some []
  | t :: ts =>
    fun f =>
      match f t (@inl (t = t) (LIn t ts) eq_refl), map_option_in ts (fun x i => f x (inr i)) with
      | Some u, Some us => Some (u :: us)
      | _, _ => None
      end
  end.

Fixpoint map_option_in_fun
         {T U}
         (l : list T)
  : (forall t, LIn t l -> option (U t)) -> option (forall t, LIn t l -> U t) :=
  match l with
  | [] => fun f => Some (fun t (i : LIn t []) => match i with end)
  | t :: ts =>
    fun (f : forall x, LIn x (t :: ts) -> option (U x)) =>
      match f t (@inl (t = t) (LIn t ts) eq_refl),
            map_option_in_fun ts (fun x i => f x (inr i)) with
      | Some u, Some g => Some (fun x (i : LIn x (t :: ts)) =>
                                   match i with
                                   | inl e => transport e u
                                   | inr j => g x j
                                   end)
      | _, _ => None
      end
  end.

Lemma map_option_in_fun2_lem :
  forall {T : Type }
         (l : list T)
         (U : forall (t : T) (i : LIn t l), Type)
         (f : forall (t : T) (i : LIn t l), option (U t i)),
    option (forall t (i : LIn t l), U t i).
Proof.
  induction l; introv f; simpl in *.
  - left; introv; destruct i.
  - pose proof (f a (inl eq_refl)) as opt1.
    destruct opt1 as [u|];[|right].
    pose proof (IHl (fun x i => U x (inr i)) (fun x i => f x (inr i))) as opt2.
    destruct opt2 as [g|];[|right].
    left.
    introv.
    destruct i as [i|i].
    + rewrite <- i.
      exact u.
    + apply g.
Defined.

Fixpoint map_option_in_fun2
         {T : Type }
         (l : list T)
  : forall (U : forall (t : T) (i : LIn t l), Type),
    (forall (t : T) (i : LIn t l), option (U t i))
    -> option (forall t (i : LIn t l), U t i) :=
  match l with
  | [] => fun U f => Some (fun t (i : LIn t []) => match i with end)
  | t :: ts =>
    fun (U : forall (x : T) (i : LIn x (t :: ts)), Type)
        (f : forall x (i : LIn x (t :: ts)), option (U x i)) =>
      match f t (@inl (t = t) (LIn t ts) eq_refl),
            @map_option_in_fun2 T ts (fun x i => U x (inr i)) (fun x i => f x (inr i))
            return option (forall x (i : LIn x (t :: ts)), U x i)
      with
      | Some u, Some g => Some (fun x (i : LIn x (t :: ts)) =>
                                  match i as s return U x s with
                                  | inl e =>
                                    internal_eq_rew_dep
                                      T t
                                      (fun (x : T) (i : t = x) => U x injL(i))
                                      u x e
                                  | inr j => g x j
                                  end)
      | _, _ => None
      end
  end.

Fixpoint finish_pre_proof
         {o} {seq : @pre_baresequent o} {h : bool} {lib}
         (prf: pre_proof h lib seq) : option (pre_proof false lib seq) :=
  match prf with
  | pre_proof_hole s e => None
  | pre_proof_isect_eq a1 a2 b1 b2 x1 x2 y i H niyH pa pb =>
    match finish_pre_proof pa, finish_pre_proof pb with
    | Some p1, Some p2 => Some (pre_proof_isect_eq _ _ a1 a2 b1 b2 x1 x2 y i H niyH p1 p2)
    | _, _ => None
    end
  | pre_proof_approx_refl a H => Some (pre_proof_approx_refl _ _ a H)
  | pre_proof_cequiv_approx a b H p1 p2 =>
    match finish_pre_proof p1, finish_pre_proof p2 with
    | Some p1, Some p2 => Some (pre_proof_cequiv_approx _ _ a b H p1 p2)
    | _, _ => None
    end
  | pre_proof_approx_eq a1 a2 b1 b2 i H p1 p2 =>
    match finish_pre_proof p1, finish_pre_proof p2 with
    | Some p1, Some p2 => Some (pre_proof_approx_eq _ _ a1 a2 b1 b2 i H p1 p2)
    | _, _ => None
    end
  | pre_proof_cequiv_eq a1 a2 b1 b2 i H p1 p2 =>
    match finish_pre_proof p1, finish_pre_proof p2 with
    | Some p1, Some p2 => Some (pre_proof_cequiv_eq _ _ a1 a2 b1 b2 i H p1 p2)
    | _, _ => None
    end
  | pre_proof_bottom_diverges x H J => Some (pre_proof_bottom_diverges _ _ x H J)
  | pre_proof_cut B C x H wB cBH nixH pu pt =>
    match finish_pre_proof pu, finish_pre_proof pt with
    | Some p1, Some p2 => Some (pre_proof_cut _ _ B C x H wB cBH nixH p1 p2)
    | _, _ => None
    end
  | pre_proof_equal_in_base a b H p1 pl =>
    let op := map_option_in_fun (free_vars a) (fun v i => finish_pre_proof (pl v i)) in
    match finish_pre_proof p1, op with
    | Some p1, Some g => Some (pre_proof_equal_in_base _ _ a b H p1 g)
    | _, _ => None
    end
  | pre_proof_hypothesis x A G J => Some (pre_proof_hypothesis _ _ x A G J)
  | pre_proof_cequiv_subst_concl C x a b H wa wb ca cb p1 p2 =>
    match finish_pre_proof p1, finish_pre_proof p2 with
    | Some p1, Some p2 => Some (pre_proof_cequiv_subst_concl _ _ C x a b H wa wb ca cb p1 p2)
    | _, _ => None
    end
  | pre_proof_approx_member_eq a b H p1 =>
    match finish_pre_proof p1 with
    | Some p1 => Some (pre_proof_approx_member_eq _ _ a b H p1)
    | _ => None
    end
  | pre_proof_cequiv_computation a b H r => Some (pre_proof_cequiv_computation _ _ a b H r)
  | pre_proof_function_elimination A B C a f x z H J wa cova nizH nizJ dzf p1 p2 =>
    match finish_pre_proof p1, finish_pre_proof p2 with
    | Some p1, Some p2 => Some (pre_proof_function_elimination _ _ A B C a f x z H J wa cova nizH nizJ dzf p1 p2)
    | _, _ => None
    end
  end.

Definition pre2conclusion {o} (c : @pre_conclusion o) (e : @NTerm o) :=
  match c with
  | pre_concl_ext T => concl_ext T e
  | pre_concl_typ T => concl_typ T
  end.

Definition pre2baresequent {o} (s : @pre_baresequent o) (e : @NTerm o) :=
  mk_baresequent
    (pre_hyps s)
    (pre2conclusion (pre_concl s) e).

Definition ExtractProof {o} (seq : @pre_baresequent o) lib :=
  {e : NTerm & proof lib (pre2baresequent seq e)}.

Definition mkExtractProof {o} {lib}
           (seq : @pre_baresequent o)
           (e : @NTerm o)
           (p : proof lib (pre2baresequent seq e))
  : ExtractProof seq lib :=
  existT _ e p.

(* converts a pre-proof without holes to a proof without holes by
 * generating the extract
 *)
Fixpoint pre_proof2iproof
         {o} {seq : @pre_baresequent o} {lib}
         (prf : pre_proof false lib seq)
  : ExtractProof seq lib  :=
  match prf with
  | pre_proof_hole s e => match e with end
  | pre_proof_isect_eq a1 a2 b1 b2 x1 x2 y i H niyH pa pb =>
    match pre_proof2iproof pa, pre_proof2iproof pb with
    | existT e1 p1, existT e2 p2 =>
      mkExtractProof
        (pre_rule_isect_equality_concl a1 a2 x1 x2 b1 b2 i H)
        mk_axiom
        (proof_isect_eq _ a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH p1 p2)
 (* I need to generalize the rule a bit to allow any extract in subgoals *)
    end
  | pre_proof_approx_refl a H =>
    mkExtractProof
      (pre_rule_approx_refl_concl a H)
      mk_axiom
      (proof_approx_refl _ a H)
  | pre_proof_cequiv_approx a b H p1 p2 =>
    match pre_proof2iproof p1, pre_proof2iproof p2 with
    | existT e1 p1, existT e2 p2 =>
      mkExtractProof
        (pre_rule_cequiv_approx_concl a b H)
        mk_axiom
        (proof_cequiv_approx _ a b e1 e2 H p1 p2)
    end
  | pre_proof_approx_eq a1 a2 b1 b2 i H p1 p2 =>
    match pre_proof2iproof p1, pre_proof2iproof p2 with
    | existT e1 p1, existT e2 p2 =>
      mkExtractProof
        (pre_rule_approx_eq_concl a1 a2 b1 b2 i H)
        mk_axiom
        (proof_approx_eq _ a1 a2 b1 b2 e1 e2 i H p1 p2)
    end
  | pre_proof_cequiv_eq a1 a2 b1 b2 i H p1 p2 =>
    match pre_proof2iproof p1, pre_proof2iproof p2 with
    | existT e1 p1, existT e2 p2 =>
      mkExtractProof
        (pre_rule_cequiv_eq_concl a1 a2 b1 b2 i H)
        mk_axiom
        (proof_cequiv_eq _ a1 a2 b1 b2 e1 e2 i H p1 p2)
    end
  | pre_proof_bottom_diverges x H J =>
    mkExtractProof
      (pre_rule_bottom_diverges_concl x H J)
      mk_bottom
      (proof_bottom_diverges _ x H J)
  | pre_proof_cut B C x H wB cBH nixH pu pt =>
    match pre_proof2iproof pu, pre_proof2iproof pt with
    | existT u p1, existT t p2 =>
      mkExtractProof
        (pre_rule_cut_concl H C)
        (subst t x u)
        (proof_cut _ B C t u x H wB cBH nixH p1 p2)
    end
  | pre_proof_equal_in_base a b H p1 pl =>
    let F := fun v (i : LIn v (free_vars a)) => pre_proof2iproof (pl v i) in
    let E := fun v i => projT1 (F v i) in
    let P := fun v i => projT2 (F v i) in
    match pre_proof2iproof p1 with
    | existT e p1 =>
      mkExtractProof
        (pre_rule_equal_in_base_concl a b H)
        mk_axiom
        (proof_equal_in_base _ a b e E H p1 P)
    end
  | pre_proof_hypothesis x A G J =>
    mkExtractProof
      (pre_rule_hypothesis_concl G J A x)
      (mk_var x)
      (proof_hypothesis _ x A G J)
  | pre_proof_cequiv_subst_concl C x a b H wa wb ca cb p1 p2 =>
    match pre_proof2iproof p1, pre_proof2iproof p2 with
    | existT t p1, existT e p2 =>
      mkExtractProof
        (pre_rule_cequiv_subst_hyp1 H x C a)
        t
        (proof_cequiv_subst_concl _ C x a b t e H wa wb ca cb p1 p2)
    end
  | pre_proof_approx_member_eq a b H p1 =>
    match pre_proof2iproof p1 with
    | existT e1 p1 =>
      mkExtractProof
        (pre_rule_approx_member_eq_concl a b H)
        mk_axiom
        (proof_approx_member_eq _ a b e1 H p1)
    end
  | pre_proof_cequiv_computation a b H r =>
    mkExtractProof
      (pre_rule_cequiv_concl a b H)
      mk_axiom
      (proof_cequiv_computation _ a b H r)
  | pre_proof_function_elimination A B C a f x z H J wa cova nizH nizJ dzf p1 p2 =>
    match pre_proof2iproof p1, pre_proof2iproof p2 with
    | existT ea p1, existT e p2 =>
      mkExtractProof
        (pre_rule_function_elimination_concl A B C f x H J)
        (subst e z mk_axiom)
        (proof_function_elimination _ A B C a e ea f x z H J wa cova nizH nizJ dzf p1 p2)
    end
  end.

Lemma test {o} :
  @sequent_true2 o emlib (mk_baresequent [] (mk_conclax ((mk_member mk_axiom mk_unit)))).
Proof.
  apply valid_proof;
  [ exact (eq_refl, (eq_refl, eq_refl))
  | exact (proof_approx_member_eq emlib (mk_axiom) (mk_axiom) (mk_axiom) (nil) (proof_approx_refl emlib (mk_axiom) (nil)))
          (* This last bit was generated by JonPRL; I've got to generate the whole thing now *)
  ].
Qed.


(*
Inductive test : nat -> Type :=
| Foo : test 1
| Bar : test 0.

(* works *)
Definition xxx {n : nat} (t : test n) : test n :=
  match t with
  | Foo => Foo
  | Bar => Bar
  end.

(* works *)
Definition yyy {n : nat} (t : test n) : test n :=
  match t with
  | Foo => Foo
  | x => x
  end.

(* works *)
Definition www {n : nat} (t : test n) : option (test n) :=
  match t with
  | Foo => Some Foo
  | Bar => None
  end.

(* doesn't work *)
Definition zzz {n : nat} (t : test n) : test n :=
  match t with
  | Foo => Foo
  | Bar => t
  end.
*)

Definition proof_update_fun {o} lib (s seq : @baresequent o) :=
  proof lib s -> proof lib seq.

Definition proof_update {o} lib (seq : @baresequent o) :=
  {s : @baresequent o & proof_update_fun lib s seq}.

Definition ProofUpdate {o} lib (seq : @baresequent o) :=
  option (proof_update lib seq).

Definition retProofUpd
           {o} {lib} {seq : @baresequent o}
           (s : @baresequent o)
           (f : proof lib s -> proof lib seq)
  : ProofUpdate lib seq :=
  Some (existT _ s f).

Definition idProofUpd
           {o} {lib}
           (seq : @baresequent o)
  : ProofUpdate lib seq :=
  retProofUpd seq (fun p => p).

Definition noProofUpd {o} {lib} {seq : @baresequent o}
  : ProofUpdate lib seq :=
  None.

Definition bindProofUpd
           {o} {lib} {seq1 seq2 : @baresequent o}
           (pu  : ProofUpdate lib seq1)
           (puf : proof lib seq1 -> proof lib seq2)
  : ProofUpdate lib seq2 :=
  match pu with
  | Some (existT s f) => retProofUpd s (fun p => puf (f p))
  | None => None
  end.

Definition address := list nat.

Fixpoint get_sequent_fun_at_address {o}
         {lib}
         {seq  : @baresequent o}
         (prf  : proof lib seq)
         (addr : address) : ProofUpdate lib seq :=
  match prf with
  | proof_isect_eq a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH pa pb =>
    match addr with
    | [] => idProofUpd (rule_isect_equality_concl a1 a2 x1 x2 b1 b2 i H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address pa addr)
        (fun x => proof_isect_eq _ a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH x pb)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address pb addr)
        (fun x => proof_isect_eq _ a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH pa x)
    | _ => noProofUpd
    end
  | proof_approx_refl a H =>
    match addr with
    | [] => idProofUpd (rule_approx_refl_concl a H)
    | _ => noProofUpd
    end
  | proof_cequiv_approx a b e1 e2 H p1 p2 =>
    match addr with
    | [] => idProofUpd (rule_cequiv_approx_concl a b H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun x => proof_cequiv_approx _ a b e1 e2 H x p2)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p2 addr)
        (fun x => proof_cequiv_approx _ a b e1 e2 H p1 x)
    | _ => noProofUpd
    end
  | proof_approx_eq a1 a2 b1 b2 e1 e2 i H p1 p2 =>
    match addr with
    | [] => idProofUpd (rule_approx_eq_concl a1 a2 b1 b2 i H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun x => proof_approx_eq _ a1 a2 b1 b2 e1 e2 i H x p2)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p2 addr)
        (fun x => proof_approx_eq _ a1 a2 b1 b2 e1 e2 i H p1 x)
    | _ => noProofUpd
    end
  | proof_cequiv_eq a1 a2 b1 b2 e1 e2 i H p1 p2 =>
    match addr with
    | [] => idProofUpd (rule_cequiv_eq_concl a1 a2 b1 b2 i H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun x => proof_cequiv_eq _ a1 a2 b1 b2 e1 e2 i H x p2)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p2 addr)
        (fun x => proof_cequiv_eq _ a1 a2 b1 b2 e1 e2 i H p1 x)
    | _ => noProofUpd
    end
  | proof_bottom_diverges x H J =>
    match addr with
    | [] => idProofUpd (rule_bottom_diverges_concl x H J)
    | _ => noProofUpd
    end
  | proof_cut B C t u x H wB cBH nixH pu pt =>
    match addr with
    | [] => idProofUpd (rule_cut_concl H C t x u)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address pu addr)
        (fun z => proof_cut _ B C t u x H wB cBH nixH z pt)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address pt addr)
        (fun z => proof_cut _ B C t u x H wB cBH nixH pu z)
    | _ => noProofUpd
    end
  | proof_equal_in_base a b e F H p1 pl =>
    match addr with
    | [] => idProofUpd (rule_equal_in_base_concl a b H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun z => proof_equal_in_base _ a b e F H z pl)
    | _ => noProofUpd (* TODO *)
    end
  | proof_hypothesis x A G J =>
    match addr with
    | [] => idProofUpd (rule_hypothesis_concl G J A x)
    | _ => noProofUpd
    end
  | proof_cequiv_subst_concl C x a b t e H wa wb ca cb p1 p2 =>
    match addr with
    | [] => idProofUpd (rule_cequiv_subst_hyp1 H x C a t)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun z => proof_cequiv_subst_concl _ C x a b t e H wa wb ca cb z p2)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p2 addr)
        (fun z => proof_cequiv_subst_concl _ C x a b t e H wa wb ca cb p1 z)
    | _ => noProofUpd
    end
  | proof_approx_member_eq a b e H p1 =>
    match addr with
    | [] => idProofUpd (rule_approx_member_eq_concl a b H)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun z => proof_approx_member_eq _ a b e H z)
    | _ => noProofUpd
    end
  | proof_cequiv_computation a b H r =>
    match addr with
    | [] => idProofUpd (rule_cequiv_concl a b H)
    | _ => noProofUpd
    end
  | proof_function_elimination A B C a e ea f x z H J wa cova nizH nizJ dzf p1 p2 =>
    match addr with
    | [] => idProofUpd (rule_function_elimination_concl A B C e f x z H J)
    | 1 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p1 addr)
        (fun p => proof_function_elimination _ A B C a e ea f x z H J wa cova nizH nizJ dzf p p2)
    | 2 :: addr =>
      bindProofUpd
        (get_sequent_fun_at_address p2 addr)
        (fun p => proof_function_elimination _ A B C a e ea f x z H J wa cova nizH nizJ dzf p1 p)
    | _ => noProofUpd
    end
  end.

Fixpoint get_sequent_at_address {o}
           {seq  : @baresequent o}
           {lib}
           (prf  : proof lib seq)
           (addr : address) : option baresequent :=
  match get_sequent_fun_at_address prf addr with
  | Some (existT s _) => Some s
  | _ => None
  end.

Definition list1 {T} : forall a : T, LIn a [a].
Proof.
  tcsp.
Qed.


(* Looking at how we can define a Nuprl process *)

Inductive command {o} :=
(* add a definition at the head *)
| COM_add_def :
    forall (opabs   : opabs)
           (vars    : list sovar_sig)
           (rhs     : @SOTerm o)
           (correct : correct_abs opabs vars rhs),
      command
(* tries to complete a proof if it has no holes *)
| COM_finish_proof :
    ProofName -> command
(* focuses to a node in a proof *)
| COM_focus_proof :
    ProofName -> address -> command.

Definition proof_library {o} lib := list (@proof_library_entry o lib).

Record proof_update_seq {o} lib :=
  MkProofUpdateSeq
    {
      PUS_name  : ProofName;
      PUS_seq   : @baresequent o;
      PUS_focus : baresequent;
      PUS_upd   : proof_update_fun lib PUS_focus PUS_seq
    }.

Definition ProofUpdateSeq {o} lib :=
  option (@proof_update_seq o lib).

Record NuprlState {o} :=
  MkNuprlState
    {
      NuprlState_def_library   : @library o;
      NuprlState_proof_library : @proof_library o NuprlState_def_library;
      NuprlState_focus         : @ProofUpdateSeq o NuprlState_def_library
    }.

Fixpoint proof_consistent_with_new_definition
         {o} {seq : @baresequent o} {lib}
         (prf : proof lib seq)
         (e   : library_entry)
         (p   : !in_lib (opabs_of_lib_entry e) lib)
  : proof (e :: lib) seq :=
  match prf with
  | proof_isect_eq a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH pa pb =>
    let p1 := proof_consistent_with_new_definition pa e p in
    let p2 := proof_consistent_with_new_definition pb e p in
    proof_isect_eq _ a1 a2 b1 b2 e1 e2 x1 x2 y i H niyH p1 p2
  | proof_approx_refl a H => proof_approx_refl _ a H
  | proof_cequiv_approx a b e1 e2 H p1 p2 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let p2 := proof_consistent_with_new_definition p2 e p in
    proof_cequiv_approx _ a b e1 e2 H p1 p2
  | proof_approx_eq a1 a2 b1 b2 e1 e2 i H p1 p2 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let p2 := proof_consistent_with_new_definition p2 e p in
    proof_approx_eq _ a1 a2 b1 b2 e1 e2 i H p1 p2
  | proof_cequiv_eq a1 a2 b1 b2 e1 e2 i H p1 p2 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let p2 := proof_consistent_with_new_definition p2 e p in
    proof_cequiv_eq _ a1 a2 b1 b2 e1 e2 i H p1 p2
  | proof_bottom_diverges x H J => proof_bottom_diverges _ x H J
  | proof_cut B C t u x H wB cBH nixH pu pt =>
    let p1 := proof_consistent_with_new_definition pu e p in
    let p2 := proof_consistent_with_new_definition pt e p in
    proof_cut _ B C t u x H wB cBH nixH p1 p2
  | proof_equal_in_base a b ee F H p1 pl =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let g := fun v (i : LIn v (free_vars a)) => proof_consistent_with_new_definition (pl v i) e p in
    proof_equal_in_base _ a b ee F H p1 g
  | proof_hypothesis x A G J => proof_hypothesis _ x A G J
  | proof_cequiv_subst_concl C x a b t ee H wa wb ca cb p1 p2 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let p2 := proof_consistent_with_new_definition p2 e p in
    proof_cequiv_subst_concl _ C x a b t ee H wa wb ca cb p1 p2
  | proof_approx_member_eq a b ee H p1 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    proof_approx_member_eq _ a b ee H p1
  | proof_cequiv_computation a b H r =>
    proof_cequiv_computation
      _ a b H
      (reduces_to_consistent_with_new_definition a b r e p)
  | proof_function_elimination A B C a ee ea f x z H J wa cova nizH nizJ dzf p1 p2 =>
    let p1 := proof_consistent_with_new_definition p1 e p in
    let p2 := proof_consistent_with_new_definition p2 e p in
    proof_function_elimination _ A B C a ee ea f x z H J wa cova nizH nizJ dzf p1 p2
  end.

Definition NuprlState_add_def_lib {o}
           (state   : @NuprlState o)
           (opabs   : opabs)
           (vars    : list sovar_sig)
           (rhs     : SOTerm)
           (correct : correct_abs opabs vars rhs) : NuprlState :=
  let lib := NuprlState_def_library state in
  match in_lib_dec opabs lib with
  | inl _ => state
  | inr p =>
    @MkNuprlState
      o
      (lib_abs opabs vars rhs correct :: lib)
      (NuprlState_proof_library state)
      (NuprlState_focus state)
  end.

Definition NuprlState_upd_proof_lib {o}
           (state : @NuprlState o)
           (lib   : @proof_library o) : NuprlState :=
  @MkNuprlState
    o
    (NuprlState_def_library state)
    lib
    (NuprlState_focus state).

Definition NuprlState_upd_focus {o}
           (state : @NuprlState o)
           (upd   : @ProofUpdateSeq o) : NuprlState :=
  @MkNuprlState
    o
    (NuprlState_def_library state)
    (NuprlState_proof_library state)
    upd.

Definition proof_library_entry_upd_proof {o} {lib}
           (e : @proof_library_entry o lib)
           (p : proof lib (proof_library_entry_seq lib e))
  : proof_library_entry lib :=
  MkProofLibEntry
    _
    _
    (proof_library_entry_name _ e)
    (proof_library_entry_seq _ e)
    h
    p.

Fixpoint finish_proof_in_library {o}
           (lib : @proof_library o)
           (name : ProofName) : proof_library :=
  match lib with
  | [] => []
  | p :: ps =>
    if String.string_dec (proof_library_entry_name p) name
    then if proof_library_entry_hole p (* no need to finish the proof if it is already finished *)
         then let p' := option_with_default
                          (option_map (fun p' => proof_library_entry_upd_proof p p')
                                      (finish_proof (proof_library_entry_proof p)))
                          p
              in p' :: ps
         else p :: ps
    else p :: finish_proof_in_library ps name
  end.

Fixpoint focus_proof_in_library {o}
           (lib : @proof_library o)
           (name : ProofName)
           (addr : address) : ProofUpdateSeq :=
  match lib with
  | [] => None
  | p :: ps =>
    if String.string_dec (proof_library_entry_name p) name
    then match get_sequent_fun_at_address (proof_library_entry_proof p) addr with
         | Some (existT s f) =>
           Some (MkProofUpdateSeq
                   o
                   name
                   (proof_library_entry_hole p)
                   (proof_library_entry_seq p)
                   s
                   f)
         | None => None
         end
    else focus_proof_in_library ps name addr
  end.

Definition update {o}
           (state : @NuprlState o)
           (com   : command) : NuprlState :=
  match com with
  | COM_add_def opabs vars rhs correct =>
    NuprlState_add_def_lib state opabs vars rhs correct
  | COM_finish_proof name =>
    let lib := NuprlState_proof_library state in
    NuprlState_upd_proof_lib state (finish_proof_in_library lib name)
  | COM_focus_proof name addr =>
    let lib := NuprlState_proof_library state in
    NuprlState_upd_focus state (focus_proof_in_library lib name addr)
  end.

CoInductive Loop {o} : Type :=
| proc : (@command o -> Loop) -> Loop.

CoFixpoint loop {o} (state : @NuprlState o) : Loop :=
  proc (fun c => loop (update state c)).


(*
*** Local Variables:
*** coq-load-path: ("." "../util/" "../terms/" "../computation/" "../cequiv/" "../close/" "../per/")
*** End:
*)
