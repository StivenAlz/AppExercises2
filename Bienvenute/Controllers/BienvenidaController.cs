using Bienvenute.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Bienvenute.Controllers;

[ApiController]
[Route("[controller]")]
public class BienvenidaController : ControllerBase
{
    private readonly AppDbContext _context;

    public BienvenidaController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var saludo = await _context.Saludos
            .OrderBy(r => EF.Functions.Random())
            .FirstOrDefaultAsync();

        if (saludo == null)
            return NotFound("No hay saludos disponibles.");

        return Ok(new
        {
            mensaje = "¡Bienvenido! Aquí tienes un dato curioso sobre saludos en el mundo:",
            datoCurioso = saludo.Texto
        });
    }
}