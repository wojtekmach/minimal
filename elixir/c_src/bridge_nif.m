#define STATIC_ERLANG_NIF_LIBNAME bridge_nif
#include <erl_nif.h>
#include <unistd.h>
#include <string.h>

ERL_NIF_TERM (*bridge_command_handler)(ErlNifEnv*, int, const ERL_NIF_TERM*);

static ERL_NIF_TERM bridge_command_wrapper(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return (*bridge_command_handler)(env, argc, argv);
}

static ErlNifFunc nif_funcs[] =
{
    {"command", 1, bridge_command_wrapper}
};

ERL_NIF_INIT(Elixir.Bridge.NIF, nif_funcs, NULL, NULL, NULL, NULL)
