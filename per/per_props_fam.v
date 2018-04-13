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


Require Export nuprl_props.
Require Export choice.
Require Export cvterm.


Definition pair2lib_per {o}
           {lib : SL} {A B}
           (f : {lib' : SL $ lib_extends lib' lib} -> per(o))
           (p : forall a, nuprl (projT1 a) A B (f a)): lib-per(lib,o).
Proof.
  exists (fun (lib' : SL) (ext : lib_extends lib' lib) =>
            f (existT (fun (lib' : SL) => lib_extends lib' lib) lib' ext)).

  introv.
  pose proof (p (exI(lib',e))) as a.
  pose proof (p (exI(lib',y))) as b.
  apply nuprl_refl in a.
  apply nuprl_refl in b.
  simpl in *.
  eapply nuprl_uniquely_valued; eauto.
Defined.

Lemma choice_ext_lib_teq {o} :
  forall (lib : SL) (A B : @CTerm o),
    in_ext lib (fun lib' => tequality lib' A B)
    -> {eqa : lib-per(lib,o),
        forall (lib' : SL) (e : lib_extends lib' lib), nuprl lib' A B (eqa lib' e) }.
Proof.
  introv F.

  pose proof (FunctionalChoice_on
                {lib' : SL & lib_extends lib' lib}
                per(o)
                (fun a b => nuprl (projT1 a) A B b)) as C.
  autodimp C hyp.

  {
    unfold tequality in F.
    introv; exrepnd; simpl in *; auto.
  }

  exrepnd.
  exists (pair2lib_per f C0); simpl.
  introv.
  pose proof (C0 (existT (fun (lib' : SL) => lib_extends lib' lib) lib' e)) as C.
  simpl in *; auto.
Qed.

Definition pair_dep2lib_per {o}
           {lib : SL}
           {eqa : lib-per(lib,o)}
           {v1 v2 B1 B2}
           (f : {lib' : SL $ {ext : lib_extends lib' lib $ {a1, a2 : CTerm $ eqa lib' ext a1 a2}}} -> per(o))
           (p : forall a, nuprl (projT1 a) (B1)[[v1\\projT1(projT2(projT2 a))]] (B2)[[v2\\projT1(projT2(projT2(projT2 a)))]] (f a))
  : lib-per-fam(lib,eqa,o).
Proof.
  exists (fun (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a') =>
            f (existT _ lib' (existT _ x (existT _ a (existT _ a' e))))).

  introv.
  pose proof (p (exI( lib', exI( e, exI( a, exI( b, p0)))))) as w.
  pose proof (p (exI( lib', exI( y, exI( a, exI( b, q)))))) as z.
  apply nuprl_refl in w.
  apply nuprl_refl in z.
  simpl in *.
  eapply nuprl_uniquely_valued; eauto.
Defined.

Lemma choice_ext_lib_teq_fam {o} :
  forall (lib : SL) (A1 : @CTerm o) v1 B1 A2 v2 B2 (eqa : lib-per(lib,o)),
    (forall lib' e, nuprl lib' A1 A2 (eqa lib' e))
    -> (forall (lib' : SL),
           lib_extends lib' lib
           -> forall a a' : CTerm,
             equality lib' a a' A1
             -> exists eq, nuprl lib' (B1)[[v1\\a]] (B2)[[v2\\a']] eq)
    -> {eqb : lib-per-fam(lib,eqa,o),
              forall (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a'),
                nuprl lib' (B1)[[v1\\a]] (B2)[[v2\\a']] (eqb lib' x a a' e) }.
Proof.
  introv teqa F.

  assert (forall (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a'),
             exists eq, nuprl lib' (B1) [[v1 \\ a]] (B2) [[v2 \\ a']] eq) as G.
  {
    introv e.
    apply (F lib' x a a').
    apply (equality_eq1 lib' A1 A2 a a' (eqa lib' x)); auto.
  }
  clear F; rename G into F.

  pose proof (FunctionalChoice_on
                {lib' : SL & {ext : lib_extends lib' lib & {a1 : CTerm & {a2 : CTerm & eqa lib' ext a1 a2}}}}
                per
                (fun a b => nuprl
                              (projT1 a)
                              (substc (projT1 (projT2 (projT2 a))) v1 B1)
                              (substc (projT1 (projT2 (projT2 (projT2 a)))) v2 B2)
                              b)) as C.
  autodimp C hyp.
  {
    introv; exrepnd; simpl in *.
    eapply F; eauto.
  }

  clear F.
  exrepnd.

  exists (pair_dep2lib_per f C0); simpl.
  introv; simpl in *.
  pose proof (C0 (existT _ lib' (existT _ x (existT _ a (existT _ a' e))))) as C.
  simpl in *; auto.
Qed.

Hint Resolve computes_to_valc_refl : slow.

Record lib_per_and_fam {o} {lib} :=
  MkLibPerAndFam
    {
      lpaf_eqa : lib-per(lib,o);
      lpaf_eqb : lib-per-fam(lib,lpaf_eqa,o);
    }.

Notation "bar-and-fam-per( lib , bar , o )" :=
  (forall (lib1 : SL) (br : bar_lib_bar bar lib1)
          (lib2 : SL) (ext : lib_extends lib2 lib1)
          (x : lib_extends lib2 lib),
      @lib_per_and_fam o lib2).

Lemma all_in_bar_ext_exists_per_and_fam_implies_exists {o} :
  forall {lib : SL} (bar : @BarLib o lib)
         (F : forall (lib' : SL) (x : lib_extends lib' lib) (eqa : lib-per(lib',o)) (eqb : lib-per-fam(lib',eqa,o)), Prop),
    all_in_bar_ext bar (fun (lib' : SL) x => {eqa : lib-per(lib',o) , {eqb : lib-per-fam(lib',eqa,o) , F lib' x eqa eqb }})
    ->
    exists (feqa : bar-and-fam-per(lib,bar,o)),
    forall (lib1 : SL) (br : bar_lib_bar bar lib1)
           (lib2 : SL) (ext : lib_extends lib2 lib1)
           (x : lib_extends lib2 lib),
      F lib2 x (lpaf_eqa (feqa lib1 br lib2 ext x)) (lpaf_eqb (feqa lib1 br lib2 ext x)).
Proof.
  introv h.
  pose proof (DependentFunctionalChoice_on
                (pack_lib_bar bar)
                (fun x => @lib_per_and_fam o (plb_lib2 _ x))
                (fun x e => F (plb_lib2 _ x)
                              (plb_x _ x)
                              (lpaf_eqa e)
                              (lpaf_eqb e))) as C.
  simpl in C.
  repeat (autodimp C hyp).
  { introv; destruct x; simpl in *.
    pose proof (h _ plb_br _ plb_ext plb_x) as h; simpl in *; exrepnd.
    exists (MkLibPerAndFam _ _ eqa eqb); simpl; auto. }

  exrepnd.
  exists (fun (lib1 : SL) (br : bar_lib_bar bar lib1) (lib2 : SL) (ext : lib_extends lib2 lib1) (x : lib_extends lib2 lib) =>
            (f (MkPackLibBar lib1 br lib2 ext x))).
  introv.
  pose proof (C0 (MkPackLibBar lib1 br lib2 ext x)) as w; auto.
Qed.

Definition bar_and_fam_per2lib_per {o}
           {lib  : @SL o}
           {bar  : BarLib lib}
           (feqa : bar-and-fam-per(lib,bar,o)) : lib-per(lib,o).
Proof.
  exists (fun (lib' : SL) (x : lib_extends lib' lib) t1 t2 =>
            {lib1 : SL
            , {br : bar_lib_bar bar lib1
            , {ext : lib_extends lib' lib1
            , {x : lib_extends lib' lib
            , lpaf_eqa (feqa lib1 br lib' ext x) lib' (lib_extends_refl lib') t1 t2}}}}).

  introv x y; introv.
  split; introv h; exrepnd.
  - exists lib1 br ext x0; auto.
  - exists lib1 br ext x0; auto.
Defined.

Definition lib_per_fam2lib_per {o} {lib}
           {eqa : lib-per(lib,o)}
           (a a' : @CTerm o)
           (eqb : lib-per-fam(lib,eqa,o)) : lib-per(lib,o).
Proof.
  exists (fun (lib' : SL) (x : lib_extends lib' lib) t1 t2 =>
            {e : eqa lib' x a a' ,  eqb lib' x a a' e t1 t2}).

  repeat introv.
  split; intro h; exrepnd.
  - assert (eqa lib' y a a') as f by (eapply lib_per_cond; eauto).
    exists f; eapply lib_per_fam_cond; eauto.
  - assert (eqa lib' e a a') as f by (eapply lib_per_cond; eauto).
    exists f; eapply lib_per_fam_cond; eauto.
Defined.

Definition pair_dep2lib_per2 {o}
           {lib : SL}
           {eqa : lib-per(lib,o)}
           {v B F1 F2}
           (f : {lib' : SL $ {ext : lib_extends lib' lib $ {a1, a2 : CTerm $ eqa lib' ext a1 a2}}} -> per(o))
           (p : forall a : {lib' : SL $ {ext : lib_extends lib' lib $ {a1, a2 : CTerm $ eqa lib' ext a1 a2}}},
               (nuprl (projT1 a) (B) [[v \\ projT1 (projT2 (projT2 a))]] (B) [[v \\ projT1 (projT2 (projT2 a))]] (f a))
                 # f a (F1 (projT1 (projT2 (projT2 a)))) (F2 (projT1 (projT2 (projT2 (projT2 a))))))
  : lib-per-fam(lib,eqa,o).
Proof.
  exists (fun (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a') =>
            f (existT _ lib' (existT _ x (existT _ a (existT _ a' e))))).

  introv.
  pose proof (p (exI( lib', exI( e, exI( a, exI( b, p0)))))) as w.
  pose proof (p (exI( lib', exI( y, exI( a, exI( b, q)))))) as z.
  repnd.
  simpl in *.
  eapply nuprl_uniquely_valued; eauto.
Defined.

Lemma choice_ext_lib_eq_fam {o} :
  forall (lib : SL) (A A' : @CTerm o) v B (eqa : lib-per(lib,o)) F1 F2,
    (forall lib' e, nuprl lib' A A' (eqa lib' e))
    -> (forall (lib' : SL) (x : lib_extends lib' lib) a a',
           equality lib' a a' A
           -> equality lib' (F1 a) (F2 a') (B)[[v\\a]])
    -> {eqb : lib-per-fam(lib,eqa,o),
              forall (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a'),
                nuprl lib' (B)[[v\\a]] (B)[[v\\a]] (eqb lib' x a a' e)
                      # eqb lib' x a a' e (F1 a) (F2 a')}.
Proof.
  introv teqa F.

  assert (forall (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a'),
             equality lib' (F1 a) (F2 a') (B)[[v\\a]]) as G.
  {
    introv e.
    apply (F lib' x a a').
    apply (equality_eq1 lib' A A' a a' (eqa lib' x)); auto.
  }
  clear F; rename G into F.

  pose proof (FunctionalChoice_on
                {lib' : SL & {ext : lib_extends lib' lib & {a1 : CTerm & {a2 : CTerm & eqa lib' ext a1 a2}}}}
                per
                (fun a b => nuprl
                              (projT1 a)
                              (substc (projT1 (projT2 (projT2 a))) v B)
                              (substc (projT1 (projT2 (projT2 a))) v B)
                              b
                              # b (F1 (projT1 (projT2 (projT2 a))))
                                  (F2 (projT1 (projT2 (projT2 (projT2 a))))))) as C.
  autodimp C hyp.
  {
    introv; exrepnd; simpl in *.
    eapply F; eauto.
  }

  clear F.
  exrepnd.

  exists (pair_dep2lib_per2 f C0).
  introv; simpl in *.
  pose proof (C0 (existT _ lib' (existT _ x (existT _ a (existT _ a' e))))) as C.
  simpl in *; auto.
Qed.

Definition pair_dep2lib_per3 {o}
           {lib : SL}
           {eqa : lib-per(lib,o)}
           {v1 v2 B1 B2 i}
           (f : {lib' : SL $ {ext : lib_extends lib' lib $ {a1, a2 : CTerm $ eqa lib' ext a1 a2}}} -> per(o))
           (p : forall a, nuprli i (projT1 a) (B1)[[v1\\projT1(projT2(projT2 a))]] (B2)[[v2\\projT1(projT2(projT2(projT2 a)))]] (f a))
  : lib-per-fam(lib,eqa,o).
Proof.
  exists (fun (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a') =>
            f (existT _ lib' (existT _ x (existT _ a (existT _ a' e))))).

  introv.
  pose proof (p (exI( lib', exI( e, exI( a, exI( b, p0)))))) as w.
  pose proof (p (exI( lib', exI( y, exI( a, exI( b, q)))))) as z.
  apply nuprli_refl in w.
  apply nuprli_refl in z.
  simpl in *.
  eapply nuprli_uniquely_valued; eauto.
Defined.

Lemma choice_ext_teqi {o} :
  forall (lib : SL) i (A A' : @CTerm o) v1 B1 v2 B2 (eqa : lib-per(lib,o)),
    (forall lib' e, nuprl lib' A A' (eqa lib' e))
    -> (forall (lib' : SL) (x : lib_extends lib' lib) a1 a2,
           equality lib' a1 a2 A
           -> equality lib' (substc a1 v1 B1) (substc a2 v2 B2) (mkc_uni i))
    -> {eqb : lib-per-fam(lib,eqa,o),
         forall (lib': SL) (x : lib_extends lib' lib) a1 a2 (e : eqa lib' x a1 a2),
            nuprli i lib' (substc a1 v1 B1) (substc a2 v2 B2) (eqb lib' x a1 a2 e)}.
Proof.
  introv teqa F.

  assert (forall (lib' : SL) (x : lib_extends lib' lib) a a' (e : eqa lib' x a a'),
             equality lib' (B1)[[v1\\a]] (B2)[[v2\\a']] (mkc_uni i)) as G.
  {
    introv e.
    apply (F lib' x a a').
    apply (equality_eq1 lib' A A' a a' (eqa lib' x)); auto.
  }
  clear F; rename G into F.

  pose proof (FunctionalChoice_on
                {lib' : SL & {ext : lib_extends lib' lib & {a1 : CTerm & {a2 : CTerm & eqa lib' ext a1 a2}}}}
                per
                (fun a b => nuprli
                              i
                              (projT1 a)
                              (substc (projT1 (projT2 (projT2 a))) v1 B1)
                              (substc (projT1 (projT2 (projT2 (projT2 a)))) v2 B2)
                              b)) as C.
  autodimp C hyp.
  {
    introv; exrepnd; simpl in *.
    pose proof (F lib' ext a0 a1 a3) as G.
    unfold equality in G; exrepnd.

    apply dest_nuprl_uni in G1.
    apply univ_implies_univi_bar3 in G1; exrepnd.
    apply G2 in G0.
    clear dependent eq.

    assert (exists (bar : BarLib lib'), per_bar_eq bar (univi_eq_lib_per lib' i) (substc a0 v1 B1) (substc a1 v2 B2)) as h by (exists bar; auto).
    clear dependent bar.
    unfold per_bar_eq in h; simpl in *.

    pose proof (@collapse2bars_ext o lib' (fun lib'' x => univi_eq (univi_bar i) lib'' (substc a0 v1 B1) (substc a1 v2 B2))) as q.
    simpl in q; autodimp q hyp; tcsp;[].
    apply q in h; clear q.
    exrepnd.
    unfold univi_eq in h0; fold (@nuprli o i) in *.

    apply all_in_bar_ext_exists_per_implies_exists in h0; exrepnd.
    exists (per_bar_eq bar (bar_per2lib_per feqa)).
    apply CL_bar.
    exists bar (bar_per2lib_per feqa).
    dands; tcsp;[].

    introv br xt ; introv; simpl; try (fold (@nuprli o i)).
    pose proof (h1 _ br _ xt x) as q.
    eapply nuprli_type_extensionality;[eauto|].
    introv; split; intro h.

    { exists lib'0 br xt x; auto. }

    exrepnd.
    pose proof (h1 _ br0 _ ext0 x0) as h1.
    eapply nuprli_uniquely_valued in h1; try exact q.
    apply h1; auto.
  }
  clear F.
  exrepnd.

  exists (pair_dep2lib_per3 f C0).
  introv; simpl in *.
  pose proof (C0 (existT _ lib' (existT _ x (existT _ a1 (existT _ a2 e))))) as C.
  simpl in *; auto.
Qed.
