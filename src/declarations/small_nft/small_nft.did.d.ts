import type { Principal } from '@dfinity/principal';
export interface Attribute { 'key' : string, 'value' : string }
export type Errors = { 'notFoundTokenInfo' : null } |
  { 'alreadyExist' : null };
export type Okays = { 'canTransfer' : string } |
  { 'IsSuccess' : bigint };
export type Result = { 'ok' : Okays } |
  { 'err' : Errors };
export type Result_1 = { 'ok' : string } |
  { 'err' : Errors };
export type Result_2 = { 'ok' : bigint } |
  { 'err' : string };
export interface Small_NFT {
  'latestTokenID' : () => Promise<Result_2>,
  'mint' : (arg_0: Principal, arg_1: [] | [TokenMetadata]) => Promise<TokenID>,
  'ownerOf' : (arg_0: TokenID) => Promise<Result_1>,
  'transfer' : (arg_0: Principal, arg_1: TokenID) => Promise<Result>,
}
export type TokenID = bigint;
export interface TokenMetadata { 'attributes' : [] | [Array<Attribute>] }
export interface _SERVICE extends Small_NFT {}
