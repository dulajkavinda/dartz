part of dartz;

abstract class Option<A> extends TraversableOps<Option, A> with MonadOps<Option, A>, MonadPlusOps<Option, A> {
  /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a));

  /*=B*/ cata/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => fold(ifNone, ifSome);
  Option<A> orElse(Option<A> other()) => fold(other, (_) => this);
  A getOrElse(A dflt()) => fold(dflt, (a) => a);
  Either<dynamic/*=B*/, A> toEither/*<B>*/(/*=B*/ ifNone()) => fold(() => left(ifNone()), (a) => right(a));
  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override Option/*<B>*/ pure/*<B>*/(/*=B*/ b) => some(b);
  Option/*<B>*/ map/*<B>*/(/*=B*/ f(A a)) => fold(none, (A a) => some(f(a)));
  @override Option/*<B>*/ bind/*<B>*/(Option/*<B>*/ f(A a)) => fold(none, f);

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) => fold(() => gApplicative.pure(none()), (a) => gApplicative.map(f(a), some));

  @override Option<A> empty() => none/*<A>*/();
  @override Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override String toString() => fold(() => 'None', (a) => 'Some($a)');
}

class Some<A> extends Option<A> {
  final A _a;
  Some(this._a);
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
}

class None<A> extends Option<A> {
  @override /*=B*/ fold/*<B, C extends B>*/(/*=B*/ ifNone(), /*=C*/ ifSome(A a)) => ifNone();
  @override bool operator ==(other) => other is None;
}

final Option _none = new None();
Option/*<A>*/ none/*<A>*/() => _none as dynamic/*=None<A>*/;
Option/*<A>*/ some/*<A>*/(/*=A*/ a) => new Some/*<A>*/(a);
Option/*<A>*/ option/*<A>*/(bool test, /*=A*/ value) => test ? some(value) : none();

class OptionMonadPlus extends MonadPlusOpsMonad<Option> {
  OptionMonadPlus() : super(some, none);

  @override Option/*<C>*/ map2/*<A, B, C>*/(Option/*<A>*/ fa, Option/*<B>*/ fb, /*=C*/ f(/*=A*/ a, /*=B*/ b)) => fa.bind((a) => fb.map((b) => f(a, b)));
  Option/*<C>*/ mapM2/*<A, B, C>*/(Option/*<A>*/ fa, Option/*<B>*/ fb, Option/*<C>*/ f(/*=A*/ a, /*=B*/ b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

}

final OptionMonadPlus OptionMP = new OptionMonadPlus();
final OptionMonadPlus OptionM = OptionMP;
final OptionMonadPlus OptionAP = OptionMP;
final OptionMonadPlus OptionA = OptionM;
final OptionMonadPlus OptionF = OptionM;
final Traversable<Option> OptionTr = new TraversableOpsTraversable<Option>();
final Foldable<Option> OptionFo = OptionTr;

class OptionTMonad<M> extends Monad<M> {
  Monad _stackedM;
  OptionTMonad(this._stackedM);
  Monad underlying() => OptionM;

  @override M pure(a) => _stackedM.pure(some(a)) as dynamic/*=M*/;
  @override M bind(M moa, M f(_)) => _stackedM.bind(moa, (Option o) => o.fold(() => _stackedM.pure(none()), f)) as dynamic/*=M*/;
}

Monad optionTMonad(Monad mmonad) => new OptionTMonad(mmonad);

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override Option<A> zero() => none/*<A>*/();

  @override Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(() => oa2, (a1) => oa2.fold(() => oa1, (a2) => some(_tSemigroup.append(a1, a2))));
}
