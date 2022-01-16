export const idlFactory = ({ IDL }) => {
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Attribute = IDL.Record({ 'key' : IDL.Text, 'value' : IDL.Text });
  const TokenMetadata = IDL.Record({
    'attributes' : IDL.Opt(IDL.Vec(Attribute)),
  });
  const TokenID = IDL.Nat;
  const Errors = IDL.Variant({
    'notFoundTokenInfo' : IDL.Null,
    'alreadyExist' : IDL.Null,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : Errors });
  const Okays = IDL.Variant({
    'canTransfer' : IDL.Text,
    'IsSuccess' : IDL.Nat,
  });
  const Result = IDL.Variant({ 'ok' : Okays, 'err' : Errors });
  const Small_NFT = IDL.Service({
    'latestTokenID' : IDL.Func([], [Result_2], ['query']),
    'mint' : IDL.Func([IDL.Principal, IDL.Opt(TokenMetadata)], [TokenID], []),
    'ownerOf' : IDL.Func([TokenID], [Result_1], ['query']),
    'transfer' : IDL.Func([IDL.Principal, TokenID], [Result], []),
  });
  return Small_NFT;
};
export const init = ({ IDL }) => { return []; };
